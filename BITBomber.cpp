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
#define BOMB_TIMER 4

#define MONSTER_1 41
#define MONSTER_2 42
#define MONSTER_3 43
//关于地图的define
#define ROW 11
#define COL 13
#define DEPTH 5
#define MAX_MONSTER 10
#define MAX_BOMB 5
#define MAX_TOOL 5
#define MAX_FIRE 40

//关于frac的define
#define FRAC 5

#define UP 0
#define DOWN 1
#define LEFT 2
#define RIGHT 3


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
    int speed;
};

struct Monster {
    int x;
    int y;
    int direction;
    int speed;
};

struct Bomb {
    int x;
    int y;
    int time;
    int range;
};

struct Tool {
    int valid;
    int x;
    int y;
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
    struct Object map[ROW][COL][DEPTH];//记录对象类型
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];

    struct Tool tools[MAX_TOOL];
    struct Fire fires[MAX_FIRE];
    int level = 1;
    int times;
    int monster_num = 0;
    int bomb_num = 0;
    int tool_num = 0;
    Game() {

        //set structs to zero
        memset(&player, 0, sizeof(player));
        memset(monsters, 0, sizeof(monsters));
        memset(bombs, 0, sizeof(bombs));
        memset(tools, 0, sizeof(tools));
        memset(fires, 0, sizeof(fires));

        // 初始化玩家
        player.x = player.y = 0;
        player.bomb_range = 1;
        player.bomb_cnt = 1;
        player.life = 2;
        player.speed = 1;
        map[player.x][player.y][0].type = PLAYER;

        level_init(level);
    }
    void level_init(int l) {
        //读关卡文件[level];
        FILE* file;
        const char* filename[3] = { "1.level","2.level","3.level" };
        file =
            fopen(filename[l - 1], "r");
        if (file == NULL) {
            //错误处理
            return;
        }
        monster_num = 0;
        int num;
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                fscanf(file, "%d", &num);
                switch (num) {
                case MONSTER_1:num = 4; map[i][j][0].id = monster_num; monster_init(monster_num++, i, j, 1); break;
                case MONSTER_2:num = 4; map[i][j][0].id = monster_num; monster_init(monster_num++, i, j, 2); break;
                case MONSTER_3:num = 4; map[i][j][0].id = monster_num; monster_init(monster_num++, i, j, 3); break;
                }
                map[i][j][0].type = num;
            }
        }
        fscanf(file, "%d", &times);
        fclose(file);
    }

    void monster_init(int index, int x, int y, int speed) {
        monsters[index].direction = 0;//random
        //		monsters[index].frac_x =  FRAC>>1;
        //		monsters[index].frac_y = FRAC>>1;
        monsters[index].x = x;
        monsters[index].y = y;
        monsters[index].speed = speed;
    }

    void draw() {
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                char tmp = '.';
                for (int k = DEPTH - 1; k >= 0; k--) {
                    switch (map[i][j][k].type) {
                    case WALL: tmp = '#'; break;
                    case PLAYER: tmp = 'P'; break;
                    case MONSTER: tmp = 'M'; break;
                    case BOMB: tmp = 'B'; break;
                    case BOX:tmp = '='; break;
                    case TOOL:tmp = 'T'; break;
                    }
                }
                cout << tmp;
            }
            cout << endl;
        }
        cout << "----------------------------------------" << endl;
        cout << "Life: " << player.life << endl;
        cout << "Bomb Range: " << player.bomb_range << endl;
        cout << "Bomb Count: " << player.bomb_cnt << endl;
        cout << "Speed: " << player.speed << endl;
        cout << "----------------------------------------" << endl;
    }

    void poolingPlayer(char input) {
        if (input == 'b' || input == 'B') {
            placeBomb();
            return; // Early return as no movement is required
        }
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
        if (IsMoveable(newPlayerX, newPlayerY)) {

            // Check for collision with monsters
            bool collisionWithMonster = false;
            for (int i = 0; i < monster_num; i++) {
                if (monsters[i].x == newPlayerX && monsters[i].y == newPlayerY) {
                    collisionWithMonster = true;
                    break;
                }
            }

            if (collisionWithMonster) {
                die();
            }
            if (map[newPlayerX][newPlayerY][0].type == TOOL) {
                int tool_index = map[newPlayerX][newPlayerY][0].id;
                switch (tools[tool_index].type) {
                case 0:player.life++; break;
                case 1:player.bomb_range++; break;
                case 2:player.bomb_cnt++; break;
                case 3:player.speed++; break;
                }
                map[newPlayerX][newPlayerY][0].type = EMPTY;
                map[newPlayerX][newPlayerY][0].id = -1;
                tools[tool_index].valid = 0;
            }

            // Update the player's position on the map
            map[player.x][player.y][0].type = EMPTY;
            player.x = newPlayerX;
            player.y = newPlayerY;
            map[player.x][player.y][0].type = PLAYER;
        }
    }
    void placeBomb() {
        if (player.bomb_cnt > 0) {
            // Find an empty slot for a new bomb
            for (int i = 0; i < MAX_BOMB; i++) {
                if (bombs[i].time <= 0) {  // Assuming a bomb's time <= 0 means it's inactive
                    bombs[i].x = player.x;
                    bombs[i].y = player.y;
                    bombs[i].time = BOMB_TIMER; // Set a timer for the bomb
                    bombs[i].range = player.bomb_range;
                    map[player.x][player.y][1].type = BOMB;

                    player.bomb_cnt--;
                    break;
                }

            }
        }
    }


    void poolingMonster() {
        for (int i = 0; i < monster_num; i++) {
            //判断下一步是否有两个及以上方向可走
            int direct_able = 0;
            int monster_from = 0;
            switch (monsters[i].direction) {
            case UP: monster_from = DOWN; break; // Move up
            case DOWN: monster_from = UP; break; // Move down
            case LEFT: monster_from = RIGHT; break; // Move left
            case RIGHT: monster_from = LEFT; break; // Move right
            }
            for (int j = 0; j < 4; j++) {
                int newX = monsters[i].x;
                int newY = monsters[i].y;

                switch (j) {
                case UP: newX--; break; // Move up
                case DOWN: newX++; break; // Move down
                case LEFT: newY--; break; // Move left
                case RIGHT: newY++; break; // Move right
                }
                if (IsMoveable(newX, newY) && monster_from != j) {
                    direct_able++;
                }
            }
            //get last step from monster from
            int before_x;
            int before_y;
            calculateNextMove(monsters[i].x, monsters[i].y,
                monster_from, before_x, before_y);
            if (direct_able >= 2 && IsMoveable(before_x, before_y)) {
                monsters[i].direction = changeDirection(i);
            }
            int move = monsters[i].direction;
            int newMonsterX = monsters[i].x;
            int newMonsterY = monsters[i].y;
            calculateNextMove(monsters[i].x, monsters[i].y, move, newMonsterX, newMonsterY);

            // Check if new position is valid
            if (IsMoveable(newMonsterX, newMonsterY)) {
                // Check if monster encounters the player
                if (newMonsterX == player.x && newMonsterY == player.y) {
                    die();
                }
                // Move the monster
                map[monsters[i].x][monsters[i].y][0].type = EMPTY;
                monsters[i].x = newMonsterX;
                monsters[i].y = newMonsterY;
                map[monsters[i].x][monsters[i].y][0].type = MONSTER;
            }
            else {
                // Change direction if the monster encounters a wall
                monsters[i].direction = changeDirection(i);

            }
        }
    }
    void calculateNextMove(int x, int y, int direction, int& new_x, int& new_y) {
        switch (direction) {
        case UP: new_x = x - 1; new_y = y; break; // Move up
        case DOWN: new_x = x + 1; new_y = y; break; // Move down
        case LEFT: new_x = x; new_y = y - 1; break; // Move left
        case RIGHT: new_x = x; new_y = y + 1; break; // Move right
        }
    }
    int changeDirection(int index) {
        int direction[4] = { 1,1,1,1 };
        //去掉monster来的方向
        int monster_from = 0;
        switch (monsters[index].direction) {
        case UP: monster_from = DOWN; break; // Move up
        case DOWN: monster_from = UP; break; // Move down
        case LEFT: monster_from = RIGHT; break; // Move left
        case RIGHT: monster_from = LEFT; break; // Move right
        }
        direction[monster_from] = 0;
        for (int j = 0; j < 4; j++) {
            int newX = monsters[index].x;
            int newY = monsters[index].y;
            calculateNextMove(monsters[index].x, monsters[index].y, j, newX, newY);
            if (!IsMoveable(newX, newY)) {
                direction[j] = 0;
            }
        }
        //chose the available direction randomly
        int available_direction = 0;
        int new_direction = 0;
        for (int j = 0; j < 4; j++) {
            if (direction[j] == 1) {
                new_direction = j;
                available_direction++;
            }
        }
        if (available_direction == 0) {
            return monster_from;
        }
        int random_direction = rand() % 10;
        for (int j = 0; j < random_direction; j++) {
            new_direction++;
            new_direction %= 4;
            while (1) {
                if (direction[new_direction] == 1) {
                    break;
                }
                else {
                    new_direction++;
                    new_direction %= 4;
                }
            }
        }
        monsters[index].direction = new_direction;
        return new_direction;
    }


    void poolingBomb() {
        for (int i = 0; i < MAX_BOMB; i++) {
            if (bombs[i].time > 0) {
                bombs[i].time--;
                if (bombs[i].time == 0) {
                    // Explode the bomb
                    int x = bombs[i].x;
                    int y = bombs[i].y;
                    int range = bombs[i].range;

                    // Clear the bomb
                    map[x][y][1].type = EMPTY;

                    // Explode in four directions
                    for (int j = 0; j < 4; j++) {
                        int dx = 0;
                        int dy = 0;
                        switch (j) {
                        case 0:
                            dx = -1;
                            break; // Up
                        case 1:
                            dx = 1;
                            break; // Down
                        case 2:
                            dy = -1;
                            break; // Left
                        case 3:
                            dy = 1;
                            break; // Right
                        }

                        // Explode in each direction
                        for (int k = 1; k <= range; k++) {
                            int new_x = x + dx * k;
                            int new_y = y + dy * k;

                            // Check if the new position is valid
                            if (IsDestroyable(new_x, new_y)) {
                                // Check if the bomb encounters a monster
                                clear(new_x, new_y);
                            }
                            else {
                                // Stop the explosion if the bomb encounters a wall
                                break;
                            }
                        }
                    }
                    player.bomb_cnt++;
                }
            }
        }

    }
    void poolingTool() {
        for (int i = 0; i < MAX_TOOL; i++) {
            if (tools[i].valid == 1) {
                tools[i].times--;
                if (tools[i].times == 0) {
                    // Clear the tool
                    map[tools[i].x][tools[i].y][0].type = EMPTY;
                    tools[i].valid = 0;
                }
            }
        }
    }

    void poolingSuccess() {
        if (monster_num == 0) {
            cout << "You win!" << endl;
            exit(0);
            level++;
            level_init(level);
        }
    }
    void clear(int x, int y) {
        for (int l = 0; l < monster_num; l++) {
            if (monsters[l].x == x && monsters[l].y == y) {
                // Kill the monster
                map[monsters[l].x][monsters[l].y][0].type = EMPTY;
                monsters[l].x = -1;
                monsters[l].y = -1;
                monster_num--;
                break;
            }
        }

        // Check if the bomb encounters the player
        if (x == player.x && y == player.y) {
            die();
        }

        if (map[x][y][0].type == BOX) {
            // Kill the box
            map[x][y][0].type = EMPTY;
            // Generate a tool and place it on the map
            int generate_tool = rand() % 4;
            if (generate_tool == 1) {
                placeTool(x, y);
            }

        }

    }

    int placeTool(int x, int y) {
        for (int i = 0; i < MAX_TOOL; i++) {
            if (tools[i].valid == 0) {
                tools[i].valid = 1;
                tools[i].x = x;
                tools[i].y = y;
                tools[i].type = rand() % 4;
                tools[i].times = 10;
                map[x][y][0].type = TOOL;
                map[x][y][0].id = i;
                return 1;
            }
        }
        return 0;
    }
    int IsMoveable(int x, int y) {
        if (map[x][y][1].type == BOMB) {
            return 0;
        }
        else if (map[x][y][0].type == BOX) {
            return 0;
        }
        else if (x >= 0 && x < ROW && y >= 0 && y < COL && map[x][y][0].type != WALL) {
            return 1;
        }
        else {
            return 0;
        }

    }
    int IsDestroyable(int x, int y) {
        if (map[x][y][0].type == WALL) {
            return 0;
        }
        else {
            return 1;
        }
    }

    void die() {
        player.life--;
        if (player.life == 0) {
            cout << "Game Over!" << endl;
            exit(0); // End the game
        }
        map[player.x][player.y][0].type = EMPTY;
        player.x = player.y = 0;
        map[player.x][player.y][0].type = PLAYER;

    }
    void archive() {
        FILE* file;
        file = fopen("save.bb", "w");
        fwrite(&player, 1, sizeof(struct Player), file);
        fwrite(&map, ROW * COL * DEPTH, sizeof(struct Object), file);
        fwrite(&monsters, MAX_MONSTER, sizeof(struct Monster), file);
        fwrite(&bombs, MAX_BOMB, sizeof(struct Bomb), file);
        fwrite(&tools, MAX_TOOL, sizeof(struct Tool), file);
        fwrite(&fires, MAX_FIRE, sizeof(struct Fire), file);
        fwrite(&level, 1, sizeof(int), file);
        fwrite(&times, 1, sizeof(int), file);
        fwrite(&monster_num, 1, sizeof(int), file);
        fclose(file);
    }
    void read() {
        FILE* file;
        file = fopen("save.bb", "r");
        fread(&player, 1, sizeof(struct Player), file);
        fread(&map, ROW * COL * DEPTH, sizeof(struct Object), file);
        fread(&monsters, MAX_MONSTER, sizeof(struct Monster), file);
        fread(&bombs, MAX_BOMB, sizeof(struct Bomb), file);
        fread(&tools, MAX_TOOL, sizeof(struct Tool), file);
        fread(&fires, MAX_FIRE, sizeof(struct Fire), file);
        fread(&level, 1, sizeof(int), file);
        fread(&times, 1, sizeof(int), file);
        fread(&monster_num, 1, sizeof(int), file);
        fclose(file);
    }
};

int main() {
    Game game;
    srand(time(NULL));

    while (true) {
        game.draw();
        cout << "Move (WASD) or Place Bomb (B): ";
        char input;
        cin >> input;
        game.poolingPlayer(input);
        game.poolingMonster();
        game.poolingBomb();
        game.poolingTool();
        // Additional logic here for bomb timer countdown and explosion

        system("cls"); // or system("cls") on Windows
    }


    return 0;
}
