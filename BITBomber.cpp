#include <stdio.h>
#include <stdlib.h>
#include <time.h>


//����type��define
#define EMPTY 0
#define WALL 1
#define PLAYER 2
#define BOMB 3
#define MONSTER 4
#define BOX 5
#define TOOL 6
#define FIRE 7

//���ڵ�ͼ��define
#define ROW 8
#define COL 8
#define MAX_MONSTER 5
#define MAX_BOMB 5
#define MAX_TOOL 5
#define MAX_FIRE 40

//����frac��define
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
    struct Object map[ROW][COL][2];//��¼��������
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];
    struct Tool tools[MAX_TOOL];
    struct Fire fires[MAX_FIRE];
    int times;
    int monster_num;
    int level;
    void init() {
        //��ʼ��player;
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
        //���ؿ��ļ�[level];

    ���ݹؿ��ļ���ʼ��:map���������顢times��monster_num;
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
        ��ȡ��Ұ���x;
        ��ȡ����step;
        if (x in[�ϡ��¡�����]) {
            �ж��ܲ�����;
            if (����) {
                ��(��ʵ��);
            }
            if (��������) {
                die();
            }
            if (��������) {
                �������;
                �޸��������;
                ������ʧ;
            }
            �ж��Ƿ��޸�map;
            ����ǣ��޸�map;
        }
        else if (x == ��ը��) {
            �ж��ܲ��ܷ�;
            ���ܣ���map[x][y][1]��ը��;
        }
        �������x;
    }

    void die() {
        life--;
        if (life) {
            ����;
        }
        else {
            game over;
        }
    }

    void poolingMonster() {
        ���� / ��ȡ���﷽��direction;
        if (����) {
            �ı�direction;
        }
        if (!����) {
            ��();
            �ж��Ƿ��޸�map;
            ���ǣ��޸�map;
        }
    }

    void poolingBomb() {
        bomb.time--;
        if (time == 0) {
            ��ȡx, y;
            ��ȡrange;
            �޸�map;
            for x_0, y_0 in bomb_range :
            ��û�б�ǽ���ʱ���ӻ����;
            clear();
        }
    }

    void clear() {
        if (map[x_0][y_0][0] == Player) {
            die();
        }
        else if (map[x_0][y_0][0] == Box) {
            ������ɵ���;
            �����, map[x_0][y_0][0].type = Tool;
            ����tools�����޸�map[x_0][y_0][0].id;
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
