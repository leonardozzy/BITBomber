/*
### �������

#### ģʽһ��������Ϸ

���Ǽ�����£�����AI/�Ż�ƽ�������ݶ���

����ģʽ��һ�����й̶����ߣ�����ֲ���������/���ˢ�³�

���ߣ����������٣��ݶ��������ը����Χ������ը������

С�֣����ڷ�������Ѳ�ߣ���ʼ�����������Ҵ���С�ּ�����

��ƶ�̶���ͼ

��ƴ�BOSS�������Ķ�������Ļ���ݶ������콵ը������ˮ����ˮ֮���ܷ�ը����



ʤ����������ͨ�ؿ���ɱ������С�֡�BOSS�ؿ������BOSS

��������ʱ�����Լ�ը������С�ֽӴ�



#### ģʽ����˫�˶�ս

���ǣ������������أ�

��չʾ����



#### ���µ�

##### �������

����������һ�����������Ĵ�¥G126���ң���������ѧ�Ż�ƽ��ʦ�򡶻��������ӿڼ������༶��������ļ���������MASM����������IA32֮������ս�����Ķ���

##### �ش������õ���

���ⷽʽ����

##### 3DЧ��

##### �����ƶ�

ʹ��һ��������С������

##### ��������

##### ����



#### ��ͼģ��

ά�ȣ�3D



#### չʾ����

##### ����

PPT 1min30s~2min��������ݺ͵��߽���

1�����ֹ��£��������������֣�15s

2������ģʽ��ͨ�ؿ���3DЧ��������õ��ߣ�1min

3�������ƶ���PPT�Աȣ�������Ϸչʾ��

4��BOSS�ؿ���BOSS���� 30s

5����սģʽ���ܶ�ս��20s

�浵�Ͷ���

### ��Ҫ���

UI

```C
void ShowPicture(path,x,y);//������ʾ��ͼԪ��
void PrintWords(string,x,y);
void DrawMap(struct Game* g);//���ݵ�ͼ�������ʾ��ͼ������ShowPicture��PrintWords
```

�ܶ�����һ��ʱ���źŷ�����

```C
//����type��define
#define Empty 0
#define Wall 1
#define Player 2
#define Bomb 3
#define Monster 4
#define Box 5
#define Tool 6
#define fire 7
struct Object{
  char type;
  char id;
};
struct control{
    struct Player player;
    struct Monster monsters[N];
    struct Bomb bombs[K];
    struct Tool tools[L];
    struct Fire fires[Q];
    struct Object map[M][N][2];//��¼��������
    int times;
    int monster_num;
    int level;
    void init(){
        ��ʼ��player;
        level = 1;
        level_init(level);
        while(1){
            getTimeSignal();
        }
        level_init();
    }

    void level_init(){
        ���ؿ��ļ�[level];
        ���ݹؿ��ļ���ʼ��:map���������顢times��monster_num;
    }

    void getTimeSignal(){
        times--;
        clearFire();
        poolingPlayer();
        poolingMonster();
        poolingTool();
        poolingBomb();
        if(monster_num==0){
            win();
        }
        drawMap();
    }

    void poolingPlayer(){
    	��ȡ��Ұ���x;
        ��ȡ����step;
    	if(x in [�ϡ��¡�����]){
        	�ж��ܲ�����;
        	if(����){
                ��(��ʵ��);
            }
            if(��������){
                die();
            }
            if(��������){
                �������;
                �޸��������;
                ������ʧ;
            }
        	�ж��Ƿ��޸�map;
       	 	����ǣ��޸�map;
    	}else if(x == ��ը��){
        	�ж��ܲ��ܷ�;
        	���ܣ���map[x][y][1]��ը��;
    	}
    	�������x;
	}

    void die(){
        life--;
        if(life){
        	����;
        }else{
            game over;
        }
    }

    void poolingMonster(){
        ����/��ȡ���﷽��direction;
        if(����){
            �ı�direction;
        }
        if(!����){
            ��();
            �ж��Ƿ��޸�map;
            ���ǣ��޸�map;
        }
    }

    void poolingBomb(){
        bomb.time--;
        if(time==0){
            ��ȡx,y;
            ��ȡrange;
            �޸�map;
            for x_0,y_0 in bomb_range:
            	��û�б�ǽ���ʱ���ӻ����;
            	clear();
        }
    }

    void clear(){
        if(map[x_0][y_0][0] == Player){
            die();
        }else if(map[x_0][y_0][0]==Box){
            ������ɵ���;
            �����,map[x_0][y_0][0].type = Tool;
            ����tools�����޸�map[x_0][y_0][0].id;
        }else if(map[x_0][y_0][0]!=Wall){
            map[x_0][y_0][0].type = Empty;
            map[x_0][y_0][1].type = Empty;
        }
    }

    void poolingTool(){
        tool.times--;
        if(tool.times==0){
            map[x_0][y_0][0].type = Empty;
            map[x_0][y_0][1].type = Empty;
            tool.valid = 0;
        }
    }
}

struct Player{
  	int x;
    int y;
    int frac_x;
    int frac_y;
    int speed;
    int bomb_range;
    int bomb_cnt;
    int life;
};

struct Monster{
    int x;
    int y;
    int frac_x;
    int frac_y;
    int speed;
    int direction;
};

struct Bomb{
  	int x;
    int y;
    int time;
    int range;
};
struct Tool{
    int valid;
    int type;
    int times;
}
```

*/

#include <iostream>
#include <vector>
#include <stdlib.h>
#include <time.h>
using namespace std;

//����type��define
#define EMPTY 0
#define WALL 1
#define PLAYER 2
#define BOMB 3
#define MONSTER 4
#define BOX 5
#define TOOL 6
#define FIRE 7
#define BOMB_TIMER 3
//���ڵ�ͼ��define
#define ROW 8
#define COL 8
#define DEPTH 5
#define MAX_MONSTER 1
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
    struct Object map[ROW][COL][DEPTH];//��¼��������
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];
    struct Tool tools[MAX_TOOL];
    struct Fire fires[MAX_FIRE];

    Game() {
        // ��ʼ����ͼ
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                for(int k = 0; k < DEPTH; k++){
                    map[i][j][k].type = EMPTY;
                }
            }
        }

        // ��ʼ�����
        player.x = player.y = 0;
        player.bomb_range = 1;
        player.bomb_cnt = 1;
        player.life = 1;
        map[player.x][player.y][0].type = PLAYER;

        // ��ʼ������
        for (int i = 0; i < MAX_MONSTER; i++) {
            monsters[i].x = ROW-1; // �������ĳ�ʼλ��
            monsters[i].y = COL-1;
            monsters[i].direction = 0; // �������ĳ�ʼ����
            // ������Ҫȷ�����ﲻ����һ�ǽ����
            map[monsters[i].x][monsters[i].y][0].type = MONSTER;
        }

        // ����һЩǽ��
        map[1][1][0].type = WALL;
        map[1][2][0].type = WALL;
        map[2][1][0].type = WALL;

        // ��ʼ��������ϷԪ��...
    }


    void draw() {
        for (int i = 0; i < ROW; i++) {
            for (int j = 0; j < COL; j++) {
                char tmp = '.';
                for(int k = DEPTH-1; k >= 0; k--){
                    switch (map[i][j][k].type) {
                        case WALL: tmp = '#'; break;
                        case PLAYER: tmp = 'P'; break;
                        case MONSTER: tmp = 'M'; break;
                        case BOMB: tmp = 'B'; break;

                    }
                }
                cout<<tmp;
            }
            cout << endl;
        }
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
            if (IsMoveable(newMonsterX, newMonsterY)) {
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

    int IsMoveable(int x, int y) {
        if (map[x][y][1].type == BOMB) {
            return 0;
        } else if(x >= 0 && x < ROW && y >= 0 && y < COL && map[x][y][0].type != WALL){
            return 1;
        }else{
            return 0;
        }


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
        // Additional logic here for bomb timer countdown and explosion

        system("clear"); // or system("cls") on Windows
    }


    return 0;
}
