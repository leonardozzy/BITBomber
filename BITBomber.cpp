#include <stdio.h>
#include <stdlib.h>
#include <time.h>


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
#define ROW 8
#define COL 8
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
    int frac_x;
    int frac_y;
    int speed;
    int bomb_range;
    int bomb_cnt;
    int life;
};

struct Monster {
    int x;
    int y;
    int frac_x;
    int frac_y;
    int speed;
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

struct control {
    struct Player player;
    struct Object map[ROW][COL][2];//记录对象类型
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];
    struct Tool tools[MAX_TOOL];
    struct Fire fires[MAX_FIRE];
    int times;
    int monster_num;
    int level;
    void init() {
        //初始化player;
        player_init();
        level = 1;
        level_init(level);
        while (1) {
            getTimeSignal();
        }
        level_init();
    }

    void player_init() {
        player.bomb_cnt = 1;
        player.bomb_range = 1;
        player.frac_x = FRAC >> 1;
        player.frac_x = FRAC >> 1;
        player.x = 0;
        player.y = 0;
        player.speed = 1;
        player.life = 1;
    }

    void level_init(int l) {
        //读关卡文件[level];

    根据关卡文件初始化:map、对象数组、times、monster_num;
    }

    void getTimeSignal() {
        times--;
        clearFire();
        poolingPlayer();
        poolingMonster();
        poolingTool();
        poolingBomb();
        if (monster_num == 0) {
            win();
        }
        drawMap();
    }

    void poolingPlayer() {
        获取玩家按键x;
        获取步长step;
        if (x in[上、下、左、右]) {
            判断能不能走;
            if (能走) {
                走(待实现);
            }
            if (碰到怪物) {
                die();
            }
            if (碰到道具) {
                随机出题;
                修改相关属性;
                道具消失;
            }
            判断是否修改map;
            如果是，修改map;
        }
        else if (x == 放炸弹) {
            判断能不能放;
            如能，在map[x][y][1]放炸弹;
        }
        清除按键x;
    }

    void die() {
        life--;
        if (life) {
            锁命;
        }
        else {
            game over;
        }
    }

    void poolingMonster() {
        计算 / 获取怪物方向direction;
        if (碰壁) {
            改变direction;
        }
        if (!碰壁) {
            走();
            判断是否修改map;
            如是，修改map;
        }
    }

    void poolingBomb() {
        bomb.time--;
        if (time == 0) {
            获取x, y;
            获取range;
            修改map;
            for x_0, y_0 in bomb_range :
            在没有被墙阻断时增加火对象;
            clear();
        }
    }

    void clear() {
        if (map[x_0][y_0][0] == Player) {
            die();
        }
        else if (map[x_0][y_0][0] == Box) {
            随机生成道具;
            如果有, map[x_0][y_0][0].type = Tool;
            插入tools，并修改map[x_0][y_0][0].id;
        }
        else if (map[x_0][y_0][0] != Wall) {
            map[x_0][y_0][0].type = Empty;
            map[x_0][y_0][1].type = Empty;
        }
    }

    void poolingTool() {
        tool.times--;
        if (tool.times == 0) {
            map[x_0][y_0][0].type = Empty;
            map[x_0][y_0][1].type = Empty;
            tool.valid = 0;
        }
    }
}
