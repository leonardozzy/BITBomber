#include <iostream>
#include <vector>
#include <stdlib.h>
#include <time.h>
using namespace std;

//关于type的define
#define EMPTY 0
#define WALL 1
#define PLAYER 2
#define BOMB 3
#define MONSTER 4
#define BOX 5
#define TOOL 6
#define FIRE 7

//关于地图的define
#define ROW 11
#define COL 13
#define MAX_MONSTER 5
#define MAX_BOMB 5
#define MAX_TOOL 5
#define MAX_FIRE 40

//关于frac的define
#define FRAC 5 
struct Object {
    char type;
    char id;
};

struct Player {
    int x;
    int y;
    int bomb_range;
    int bomb_cnt;
    int life;
};

struct Monster {
    int x;
    int y;
    int direction;
};

struct Bomb {
    int x;
    int y;
    int time;
    int range;
};

struct Tool {
    int valid;
    int type;
    int times;
};

struct Fire {
    int x;
    int y;
};


class Game {
public:
    struct Player player;
    struct Object map[ROW][COL][2];//记录对象类型
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];
    struct Tool tools[MAX_TOOL];
    struct Fire fires[MAX_FIRE];

    Game() {
        // 初始化地图
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                map[i][j][0].type = EMPTY; // Layer 0 (ground layer)
                map[i][j][1].type = EMPTY; // Layer 1 (object layer)
            }
        }

        // 初始化玩家
        player.x = player.y = 0;
        player.bomb_range = 1;
        player.bomb_cnt = 1;
        player.life = 1;
        map[player.x][player.y][0].type = PLAYER;

        // 初始化怪物
        for (int i = 0; i < MAX_MONSTER; i++) {
            monsters[i].x = ROW; // 定义怪物的初始位置
            monsters[i].y = COL;
            monsters[i].direction = 0; // 定义怪物的初始方向
            // 可能需要确保怪物不在玩家或墙壁上
            map[monsters[i].x][monsters[i].y][0].type = MONSTER;
        }

        // 放置一些墙壁
        map[1][1][0].type = WALL;
        map[1][2][0].type = WALL;
        map[2][1][0].type = WALL;

        // 初始化其他游戏元素...
    }


    void draw() {
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                switch (map[i][j][0].type) {
                case EMPTY: cout << "."; break;
                case WALL: cout << "#"; break;
                case PLAYER: cout << "P"; break;
                case MONSTER: cout << "M"; break;
                }
            }
            cout << endl;
        }
    }

    void poolingPlayer(char input) {
        // Move player
        int newPlayerX = player.x;
        int newPlayerY = player.y;

        switch (input) {
        case 'w': newPlayerX--; break;
        case 's': newPlayerX++; break;
        case 'a': newPlayerY--; break;
        case 'd': newPlayerY++; break;
        }

        // Check if new position is valid
        if (newPlayerX >= 0 && newPlayerX < ROW && newPlayerY >= 0 && newPlayerY < COL
            && map[newPlayerX][newPlayerY][0].type != WALL) {

            // Check for collision with monsters
            bool collisionWithMonster = false;
            for (int i = 0; i < MAX_MONSTER; i++) {
                if (monsters[i].x == newPlayerX && monsters[i].y == newPlayerY) {
                    collisionWithMonster = true;
                    break;
                }
            }

            if (collisionWithMonster) {
                cout << "Game Over: You were caught by a monster!" << endl;
                exit(0); // End the game
            }

            // Update the player's position on the map
            map[player.x][player.y][0].type = EMPTY;
            player.x = newPlayerX;
            player.y = newPlayerY;
            map[player.x][player.y][0].type = PLAYER;
        }
    }


    void poolingMonster() {
        for (int i = 0; i < MAX_MONSTER; i++) {
            // Randomly choose a direction for each monster
            int move = rand() % 4;
            int newMonsterX = monsters[i].x;
            int newMonsterY = monsters[i].y;

            switch (move) {
            case 0: newMonsterX--; break; // Move up
            case 1: newMonsterX++; break; // Move down
            case 2: newMonsterY--; break; // Move left
            case 3: newMonsterY++; break; // Move right
            }

            // Check if new position is valid
            if (newMonsterX >= 0 && newMonsterX < ROW && newMonsterY >= 0 && newMonsterY < COL
                && map[newMonsterX][newMonsterY][0].type != WALL) {
                // Check if monster encounters the player
                if (newMonsterX == player.x && newMonsterY == player.y) {
                    cout << "Game Over: You were caught by a monster!" << endl;
                    exit(0); // End the game
                }

                // Move the monster
                map[monsters[i].x][monsters[i].y][0].type = EMPTY;
                monsters[i].x = newMonsterX;
                monsters[i].y = newMonsterY;
                map[monsters[i].x][monsters[i].y][0].type = MONSTER;
            }
        }
    }



};

int main() {
    Game game;
    srand(time(NULL));

    while (true) {
        game.draw();
        cout << "Move (WASD): ";
        char input;
        cin >> input;
        game.poolingPlayer(input);
        game.poolingMonster();
        system("clear"); // 在Windows中使用system("cls");
    }

    return 0;
}
