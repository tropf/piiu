#include <iostream>

#include <map>
#include <chrono>
#include <string>
#include <algorithm>
#include <vector>
#include <regex>

#include <dlib/iosockstream.h>
#include <dlib/sockets.h>
#include <dlib/server.h>

#include <mutex>

using namespace std;
using namespace dlib;

typedef struct {
    string x, y;
    string vx, vy;
    string rotation, state;
    string hp;
    std::chrono::system_clock::time_point time;
    bool dead = false;
    std::vector<int> friends;
} playerinfo;

typedef struct {
    string x, y;
    string vx, vy;
    string state;
    string rotation;
    std::vector<int> known;
} bullet;

int next_id = 0;
std::mutex bullet_mutex;
std::mutex info_mutex;

std::map<int, playerinfo> info;
std::vector<bullet> bullets;

string bulletinfo(int id = -1) {
    string ret = "";
    bool first = true;
    for (auto& kv : bullets) {
        // check if dead:
        if (end(kv.known) == find(begin(kv.known), end(kv.known), id)) {
            if (first) {
                first = false;
            } else {
                ret += ";";
            }

            // send nomral
            ret += kv.x + ",";
            ret += kv.y + ",";
            ret += kv.vx + ",";
            ret += kv.vy + ",";
            ret += kv.rotation + ",";
            ret += kv.state;

            if (-1 != id) {
                kv.known.push_back(id);
            }
        }
    }

    return ret;
}

string getter(int id = -1) {
    string ret = "";
    bool first = true;
    std::vector<int> to_kill;
    auto now = chrono::system_clock::now();
    for (auto& kv : info) {
        if (id != kv.first) {
            // check if dead:
            if (!((kv.second.dead) && (end(kv.second.friends) != find(begin(kv.second.friends), end(kv.second.friends), id)))) {
                if (first) {
                    first = false;
                } else {
                    ret += ";";
                }
                ret += std::to_string(kv.first) + ",";
                if (kv.second.dead) {
                    // port to doom
                    ret += "0,50000,0,0,0,0";
                    // remember friend (don't tp again)
                    kv.second.friends.push_back(id);
                } else {
                    // send nomral
                    ret += kv.second.x + ",";
                    ret += kv.second.y + ",";
                    ret += kv.second.vx + ",";
                    ret += kv.second.vy + ",";
                    ret += kv.second.rotation + ",";
                    ret += kv.second.state + ",";
                    ret += kv.second.hp;
                }

                kv.second.time = chrono::system_clock::now();
            }
        }

        // check timeout
        cout <<"age: " <<id <<": " << std::chrono::duration_cast<std::chrono::seconds>(now - kv.second.time).count()<< endl;
        if (std::chrono::duration_cast<std::chrono::seconds>(now - kv.second.time).count() > 5) {
            std::cout << "timout " << endl;
            to_kill.push_back(kv.first);
        };
    }

    for (auto killer : to_kill) {
        info.erase(killer);
    }

    return ret;
}

static string handle(string str) {
    if ("/new" == str) {
        info_mutex.lock();
        int id = next_id++;
        info_mutex.unlock();
        playerinfo p;
        p.x = "0";
        p.y = "0";
        p.vx = "0";
        p.vy = "0";
        p.rotation = "0";
        p.state = "0";
        p.hp = "10";
        p.time = chrono::system_clock::now();

        info_mutex.lock();
        info[id] = p;
        info_mutex.unlock();
        return std::to_string(id);
    }

    smatch result;

    regex set_regex("\\/set\\/([0-9]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)");
    if (regex_match(str, result, set_regex)) {
        int id = std::atoi(result[1].str().c_str());
        
        playerinfo p;
        p.x = result[2].str();
        p.y = result[3].str();
        p.vx = result[4].str();
        p.vy = result[5].str();
        p.rotation = result[6].str();
        p.state = result[7].str();
        p.hp = result[8].str();
        p.time = chrono::system_clock::now();
        
        info[id] = p;
        
        info_mutex.lock();
        auto x = getter(id);
        info_mutex.unlock();
        return x;
    }

    regex fire_regex("\\/fire\\/([0-9]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)");
    if (regex_match(str, result, fire_regex)) {
        int id = std::atoi(result[1].str().c_str());
        
        bullet p;
        p.x = result[2].str();
        p.y = result[3].str();
        p.vx = result[4].str();
        p.vy = result[5].str();
        p.rotation = result[6].str();
        p.state = result[7].str();
        
        p.known.push_back(id);

        bullet_mutex.lock();
        bullets.push_back(p);
        bullet_mutex.unlock();
        return "";
    }

    regex bullets_regex("\\/bullets\\/([0-9]+)");
    if (regex_match(str, result, bullets_regex)) {
        int id = std::atoi(result[1].str().c_str());

        bullet_mutex.lock();
        auto x = bulletinfo(id);
        bullet_mutex.unlock();
        return x;
    }

    regex get_regex("\\/get\\/([0-9]+)");
    if (regex_match(str, result, get_regex)) {
        int id = std::atoi(result[1].str().c_str());

        info_mutex.lock();
        auto x = getter(id);
        info_mutex.unlock();
        return x;
    }

    if ("/get" == str) {
        info_mutex.lock();
        auto x = getter();
        info_mutex.unlock();
        return x;
    }

    regex die_regex("\\/die\\/([0-9]+)");
    if (regex_match(str, result, die_regex)) {
        int id = std::atoi(result[1].str().c_str());
        info_mutex.lock();
        info[id].dead = true;
        info[id].time = chrono::system_clock::now();
        info_mutex.unlock();
        return "";
    }

    return "";
}

class serv : public server_iostream {
    void on_connect  (
        std::istream& in,
        std::ostream& out,
        const std::string& foreign_ip,
        const std::string& local_ip,
        unsigned short foreign_port,
        unsigned short local_port,
        uint64 connection_id) {
        char ch;
        string buffer = "";
        while (in.peek() != EOF) {
            ch = in.get();

            if ('\n' != ch) {
                buffer += ch;
            } else {
                //cout << ">>> " << buffer << endl;
                if (buffer != "/nop") {
                    auto response = handle(buffer) + "\n";
//                    cout << "<<< " << response << endl;
                    out << response;
                }

                buffer = "";
            }
            // we are just reading one char at a time and writing it back
            // to the connection.  If there is some problem writing the char
            // then we quit the loop.
        }
    }
};


int main(){
    handle("/new");
    handle("/new");
    handle("/new");
    std::cout << handle("/get/0") << endl;
    std::cout << handle("/set/0/0/0/0/0/0/3/4") << endl;
    while (true) {
        try
        {
            cout << "Listening on Port 1337" << endl;
            serv our_server;

            // set up the server object we have made
            our_server.set_listening_port(1337);
            // Tell the server to begin accepting connections.
            our_server.start_async();

            std::this_thread::sleep_until(std::chrono::system_clock::now() + std::chrono::hours(std::numeric_limits<int>::max()));
        }
        catch (exception& e)
        {
            cout << e.what() << endl;
        }
    }
}
