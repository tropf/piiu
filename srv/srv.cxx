#include <iostream>
#include "crow.h"

#include <map>
#include <chrono>
#include <string>
#include <algorithm>
#include <vector>

using namespace std;

int main() {
    crow::SimpleApp app;

    typedef struct {
        string x, y;
        string vx, vy;
        std::chrono::system_clock::time_point time;
        bool dead = false;
        std::vector<int> friends;
    } playerinfo;
    int next_id = 0;

    std::map<int, playerinfo> info;

    CROW_ROUTE(app, "/")([&](){
        return "Hello world";
    });

    CROW_ROUTE(app, "/new")([&](){
        int id = next_id++;
        playerinfo p;
        p.x = "0";
        p.y = "0";
        p.vx = "0";
        p.vy = "0";
        p.time = chrono::system_clock::now();

        info[id] = p;
        return crow::response(std::to_string(id));
    });

    CROW_ROUTE(app, "/set/<int>/<string>/<string>/<string>/<string>")(
            [&](int id, string x, string y, string vx, string vy){
        playerinfo p;
        p.x = x;
        p.y = y;
        p.vx = vx;
        p.vy = vy;
        p.time = chrono::system_clock::now();
        
        info[id] = p;
        return crow::response("");
    });

    auto getter = [&](int id = -1) -> string {
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
    };

    CROW_ROUTE(app, "/get/<int>")(
            [&](int id){
        return crow::response(getter(id));
    });

    CROW_ROUTE(app, "/get")(
            [&](){
        return crow::response(getter());
    });

    CROW_ROUTE(app, "/die/<int>")(
            [&](int id){
        info[id].dead = true;
        info[id].time = chrono::system_clock::now();
        return crow::response("");
    });
    
    app.port(1337).multithreaded().run();
}
