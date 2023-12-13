/*
### 需求分析

#### 模式一：单人游戏

考虑加入故事：加入AI/张华平语音（暂定）

闯关模式：一关内有固定道具，随机分布到方块中/随机刷新出

道具：加命、加速（暂定）、提高炸弹范围、增加炸弹数量

小怪：碰壁返回区域巡逻，初始方向随机，玩家触碰小怪即死亡

设计多固定地图

设计大BOSS：北理工的恶龙、弹幕（暂定）、天降炸弹、喷水（浇水之后不能放炸弹）



胜利条件：普通关卡：杀死所有小怪、BOSS关卡：打败BOSS

死亡：超时、被自己炸死、与小怪接触



#### 模式二：双人对战

考虑：加入联机因素？

仅展示有无



#### 创新点

##### 故事情节

北理工出现了一条恶龙，向文翠楼G126教室，北京理工大学张华平老师向《汇编语言与接口技术》班级发出了招募令，赋予他们MASM的武器，以IA32之力，大战北理工的恶龙

##### 回答汇编题获得道具

答题方式待定

##### 3D效果

##### 连续移动

使用一个整数和小组坐标

##### 背景音乐

##### 联机



#### 绘图模块

维度：3D



#### 展示考虑

##### 内容

PPT 1min30s~2min：设计内容和道具介绍

1、开局故事（动画、背景音乐）15s

2、单人模式普通关卡（3D效果、汇编获得道具）1min

3、连续移动（PPT对比，加以游戏展示）

4、BOSS关卡：BOSS技能 30s

5、对战模式（能对战）20s

存档和读档

### 概要设计

UI

```C
void ShowPicture(path,x,y);//用于显示地图元素
void PrintWords(string,x,y);
void DrawMap(struct Game* g);//根据地图情况，显示地图，调用ShowPicture和PrintWords
```

总对象在一个时钟信号发生后

```C
//关于type的define
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
    struct Object map[M][N][2];//记录对象类型
    int times;
    int monster_num;
    int level;
    void init(){
        初始化player;
        level = 1;
        level_init(level);
        while(1){
            getTimeSignal();
        }
        level_init();
    }

    void level_init(){
        读关卡文件[level];
        根据关卡文件初始化:map、对象数组、times、monster_num;
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
    	获取玩家按键x;
        获取步长step;
    	if(x in [上、下、左、右]){
        	判断能不能走;
        	if(能走){
                走(待实现);
            }
            if(碰到怪物){
                die();
            }
            if(碰到道具){
                随机出题;
                修改相关属性;
                道具消失;
            }
        	判断是否修改map;
       	 	如果是，修改map;
    	}else if(x == 放炸弹){
        	判断能不能放;
        	如能，在map[x][y][1]放炸弹;
    	}
    	清除按键x;
	}

    void die(){
        life--;
        if(life){
        	锁命;
        }else{
            game over;
        }
    }

    void poolingMonster(){
        计算/获取怪物方向direction;
        if(碰壁){
            改变direction;
        }
        if(!碰壁){
            走();
            判断是否修改map;
            如是，修改map;
        }
    }

    void poolingBomb(){
        bomb.time--;
        if(time==0){
            获取x,y;
            获取range;
            修改map;
            for x_0,y_0 in bomb_range:
            	在没有被墙阻断时增加火对象;
            	clear();
        }
    }

    void clear(){
        if(map[x_0][y_0][0] == Player){
            die();
        }else if(map[x_0][y_0][0]==Box){
            随机生成道具;
            如果有,map[x_0][y_0][0].type = Tool;
            插入tools，并修改map[x_0][y_0][0].id;
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
    Game() {


        // 初始化玩家
        player.x = player.y = 0;
        player.bomb_range = 1;
        player.bomb_cnt = 1;
        player.life = 1;

        level_init(level);
    }
    
	void level_init(int l){
		//读关卡文件[level];
        FILE* file;
        const char* filename[3] = {"1.level","2.level","3.level"};
        file = fopen(filename[l-1],"r");
        if(file==NULL){
        	//错误处理
			return ;
		}
		monster_num = 0;
		int num;
    	for (int i = 0; i < ROW; i++) {
        	for (int j = 0; j < COL; j++) {
            	fscanf(file,"%d",&num);
            	switch(num){
            		case MONSTER_1:num=4;map[i][j][0].id = monster_num;monster_init(monster_num++,i,j,1);break;
            		case MONSTER_2:num=4;map[i][j][0].id = monster_num;monster_init(monster_num++,i,j,2);break;
            		case MONSTER_3:num=4;map[i][j][0].id = monster_num;monster_init(monster_num++,i,j,3);break;
				}
				map[i][j][0].type = num;
            }
        }
        fscanf(file,"%d",&times);
        fclose(file);
	}

	void monster_init(int index,int x,int y,int speed){
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
                for(int k = DEPTH-1; k >= 0; k--){
                    switch (map[i][j][k].type) {
                        case WALL: tmp = '#'; break;
                        case PLAYER: tmp = 'P'; break;
                        case MONSTER: tmp = 'M'; break;
                        case BOMB: tmp = 'B'; break;
						case BOX:tmp = '=';break;
                    }
                }
                cout<<tmp;
            }
            cout << endl;
        }
        cout<<"----------------------------------------"<<endl;
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
                    die();
                }

                // Move the monster
                map[monsters[i].x][monsters[i].y][0].type = EMPTY;
                monsters[i].x = newMonsterX;
                monsters[i].y = newMonsterY;
                map[monsters[i].x][monsters[i].y][0].type = MONSTER;
            }
        }
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
                            }else{
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

    void clear(int x, int y){
        for (int l = 0; l < monster_num; l++) {
            if (monsters[l].x == x && monsters[l].y == y) {
                // Kill the monster
                map[monsters[l].x][monsters[l].y][0].type = EMPTY;
                monsters[l].x = -1;
                monsters[l].y = -1;
                break;
            }
        }

        // Check if the bomb encounters the player
        if (x == player.x && y == player.y) {
            die();
        }
        if(map[x][y][0].type == BOX){
            // Kill the box
            map[x][y][0].type = EMPTY;
            // Generate a tool
            //TODO
        }

    }
    int IsMoveable(int x, int y) {
        if (map[x][y][1].type == BOMB) {
            return 0;
        } else if(map[x][y][0].type==BOX){
            return 0;
        }
        else if(x >= 0 && x < ROW && y >= 0 && y < COL && map[x][y][0].type != WALL){
            return 1;
        }else{
            return 0;
        }

    }
    int IsDestroyable(int x, int y) {
        if (map[x][y][0].type == WALL) {
            return 0;
        } else {
            return 1;
        }
    }

    void die() {
        player.life--;
        if (player.life == 0) {
            cout << "Game Over!" << endl;
            exit(0); // End the game
        }
    }
    
    void archive(){
		FILE* file;
		file = fopen("save.bb","w");
		fwrite(&player,1,sizeof(struct Player),file);
		fwrite(&map,ROW*COL*DEPTH,sizeof(struct Object),file);
		fwrite(&monsters,MAX_MONSTER,sizeof(struct Monster),file);
		fwrite(&bombs,MAX_BOMB,sizeof(struct Bomb),file);
		fwrite(&tools,MAX_TOOL,sizeof(struct Tool),file);
		fwrite(&fires,MAX_FIRE,sizeof(struct Fire),file);
		fwrite(&level,1,sizeof(int),file);
		fwrite(&times,1,sizeof(int),file);
		fwrite(&monster_num,1,sizeof(int),file);
		fclose(file);
	}
	void read(){
		FILE* file;
		file = fopen("save.bb","r");
		fread(&player,1,sizeof(struct Player),file);
		fread(&map,ROW*COL*DEPTH,sizeof(struct Object),file);
		fread(&monsters,MAX_MONSTER,sizeof(struct Monster),file);
		fread(&bombs,MAX_BOMB,sizeof(struct Bomb),file);
		fread(&tools,MAX_TOOL,sizeof(struct Tool),file);
		fread(&fires,MAX_FIRE,sizeof(struct Fire),file);
		fread(&level,1,sizeof(int),file);
		fread(&times,1,sizeof(int),file);
		fread(&monster_num,1,sizeof(int),file);
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
        // Additional logic here for bomb timer countdown and explosion

        //system("cls"); // or system("cls") on Windows
    }


    return 0;
}
