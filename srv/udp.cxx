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

using namespace std;
using namespace dlib;

typedef struct {
    string x, y;
    string vx, vy;
    std::chrono::system_clock::time_point time;
    bool dead = false;
    std::vector<int> friends;
} playerinfo;
int next_id = 0;

std::map<int, playerinfo> info;

string getter(int id = -1) {
    string ret = "";
    bool first = true;
    std::vector<int> to_kill;
    chrono::system_clock::time_point timeout = chrono::system_clock::now() - chrono::seconds(5);
    for (auto& kv : info) {
        if (id != kv.first) {
            // check if dead:
            if ((! kv.second.dead) || (end(kv.second.friends) == find(begin(kv.second.friends), end(kv.second.friends), id))) {
                if (first) {
                    first = false;
                } else {
                    ret += ";";
                }
                ret += std::to_string(kv.first) + ",";
                if (kv.second.dead) {
                    // port to doom
                    ret += "0,50000,0,0";
                    // remember friend (don't tp again)
                    kv.second.friends.push_back(id);
                } else {
                    // send nomral
                    ret += kv.second.x + ",";
                    ret += kv.second.y + ",";
                    ret += kv.second.vx + ",";
                    ret += kv.second.vy;
                }
            }
        }

        // check timeout
        if (kv.second.time < timeout) {
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
        int id = next_id++;
        playerinfo p;
        p.x = "0";
        p.y = "0";
        p.vx = "0";
        p.vy = "0";
        p.time = chrono::system_clock::now();

        info[id] = p;
        return std::to_string(id);
    }

    smatch result;

    regex set_regex("\\/set\\/([0-9]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)\\/([^\\/]+)");
    if (regex_match(str, result, set_regex)) {
        int id = std::atoi(result[1].str().c_str());
        
        playerinfo p;
        p.x = result[2].str();
        p.y = result[3].str();
        p.vx = result[4].str();
        p.vy = result[5].str();
        p.time = chrono::system_clock::now();
        
        info[id] = p;
        return getter(id);
    }

    regex get_regex("\\/get\\/([0-9]+)");
    if (regex_match(str, result, get_regex)) {
        int id = std::atoi(result[1].str().c_str());
        return getter(id);
    }

    if ("/get" == str) {
        return getter();
    }

    regex die_regex("\\/die\\/([0-9]+)");
    if (regex_match(str, result, die_regex)) {
        int id = std::atoi(result[1].str().c_str());
        info[id].dead = true;
        info[id].time = chrono::system_clock::now();
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
                cout << ">>> " << buffer << endl;
                if (buffer != "/nop") {
                    auto response = handle(buffer) + "\n";
                    cout << "<<< " << response << endl;
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
