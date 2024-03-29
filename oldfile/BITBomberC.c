#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

//define connectting map_element
#define EMPTY 0
#define WALL 1
#define PLAYER 2
#define BOMB 3
#define MONSTER 4
#define BOX 5
#define TOOL 6
#define FIRE 7
#define BOSS 8
#define BLUEFIRE 9
#define ATTACK 10

#define MONSTER_1 41
#define MONSTER_2 42
#define MONSTER_3 43

//define connectting speed 
#define PLAYER_1_SPEED 80
#define MONSTER_1_SPEED 60
#define MONSTER_2_SPEED 80
#define MONSTER_3_SPEED 90

//define connectting  map_size
#define ROW 13
#define COL 15
#define DEPTH 3

//define connectting max
#define MAX_MONSTER 10
#define MAX_BOMB 5
#define MAX_TOOL 5
#define MAX_ATTACK 5
#define BOSS_LIFE 5

//define connectting direction
#define UP 0
#define DOWN 1
#define LEFT 2
#define RIGHT 3
#define SETBOMB 4

//define connectting time
#define BOMB_TIMER 30
#define FIRE_TIMER 1
#define TOOL_TIMER 50
#define INVISIBLE_TIMER 5
#define COOL_TIME 30
#define SKY_TIME 30
#define PRE_DROP_TIME 10
#define PRE_ATTACK_TIME 10
#define ATTACK_TIME 5
#define ATTACK_FREQ 10

#define FRAC_RANGE 100

#define NORMAL 0
#define INVISIBLE 1

//define connectting tools (CHANGE)
#define MAX_LIFE 5
#define MAX_RANGE 4
#define MAX_BOMB_CNT 3
#define MAX_SPEED 5

struct Object {
    int type;
    int id;
};

struct Player {
    int x;
    int y;
    int frac_x;
    int frac_y;
    int bomb_range;
    int bomb_cnt;
    int life;
    int speed;
    int status;
    int timer;
};

struct Monster {
    int valid;
    int x;
    int y;
    int frac_x;
    int frac_y;
    int direction;
    int speed;
};

struct Bomb {
    int x;
    int y;
    int timer;
    int range;
};

struct Tool {
    int x;
    int y;
    int timer;
    int type;
};

struct Attack {
    int x;
    int y;
    int time;
};

struct Boss {
    int x;
    int y;
    int life;
    int cool_time;
    int sky_time;
    int pre_drop_time;
    int in_map;
};

typedef struct Game {
    struct Player player;
    struct Object map[ROW][COL][DEPTH];
    struct Monster monsters[MAX_MONSTER];
    struct Bomb bombs[MAX_BOMB];
    struct Tool tools[MAX_TOOL];
    struct Attack attacks[MAX_ATTACK];
    struct Boss boss;
    int level;
    int timer;
    int level_timer;
    int monster_num;
    int bomb_num;
    int tool_num;
} Game;

void monster_init(Game* this, int index, int x, int y, int speed) {
    this->monsters[index].direction = 0;
    this->monsters[index].x = x;
    this->monsters[index].y = y;
    this->monsters[index].frac_x = 0;
    this->monsters[index].frac_y = 0;
    this->monsters[index].speed = speed;
    this->monsters[index].valid = 1;
}

void boss_init(Game* this, int x, int y) {
    this->map[x][y][1].type = BOSS;
    this->boss.x = x;
    this->boss.y = y;
    this->boss.cool_time = COOL_TIME;
    this->boss.in_map = 1;
    this->boss.pre_drop_time = 0;
    this->boss.sky_time = 0;
    this->boss.life = BOSS_LIFE;
}

void level_init(Game* this) {
    memset(this->map, 0, ROW * COL * DEPTH * sizeof(struct Object));
    FILE* file;
    const char* filename[4] = { "1.level","2.level","3.level","4.level" };
    file = fopen(filename[this->level - 1], "r");
    if (file == NULL) {
        exit(0);//file not found 
        return;
    }
    this->monster_num = 0;
    int num;
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            fscanf(file, "%d", &num);
            switch (num) {
            case MONSTER_1:num = 4; this->map[i][j][1].id = this->monster_num; monster_init(this, this->monster_num++, i, j, MONSTER_1_SPEED); break;
            case MONSTER_2:num = 4; this->map[i][j][1].id = this->monster_num; monster_init(this, this->monster_num++, i, j, MONSTER_2_SPEED); break;
            case MONSTER_3:num = 4; this->map[i][j][1].id = this->monster_num; monster_init(this, this->monster_num++, i, j, MONSTER_3_SPEED); break;
            case BOSS:boss_init(this, i, j); this->monster_num = 1;
            }
            this->map[i][j][1].type = num;
        }
    }
    fscanf(file, "%d", &this->timer);
    fclose(file);
}

void initGame(Game* this) {
    memset(this, 0, sizeof(Game));
    this->level = 1;

    //init player
    this->player.x = 1;
    this->player.y = 1;
    this->player.frac_x = 0;
    this->player.frac_y = 0;
    this->player.bomb_range = 1;
    this->player.bomb_cnt = 1;
    this->player.life = 2;
    this->player.speed = PLAYER_1_SPEED;
    this->player.status = NORMAL;
    this->map[0][0][1].type = PLAYER;

    level_init(this);
}

void draw(Game* this) {
    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            char tmp = '.';
            for (int k = 0; k < DEPTH; k++) {
                switch (this->map[i][j][k].type) {
                case WALL: tmp = '#'; break;
                case PLAYER: tmp = 'P'; break;
                case MONSTER: tmp = 'M'; break;
                case BOMB: tmp = 'B'; break;
                case BOX:tmp = '='; break;
                case TOOL:tmp = 'T'; break;
                case FIRE:tmp = 'F'; break;
                case BLUEFIRE:tmp = 'W'; break;
                case ATTACK:tmp = 'A'; break;
                case BOSS:tmp = 'D'; break;
                }
            }
            putchar(tmp);
        }
        putchar('\n');
    }
    puts("----------------------------------------");
    printf("Life: %d\n", this->player.life);
    printf("Bomb Range: %d\n", this->player.bomb_range);
    printf("Bomb Count: %d\n", this->player.bomb_cnt);
    printf("Speed: %d\n", this->player.speed);
    printf("Monster Num: %d\n", this->monster_num);
    puts("----------------------------------------");
}

int isMoveableMonster(Game* this, int x, int y) {
    if (!isMoveable(this, x, y) || this->map[x][y][1].type == MONSTER) {
        return 0;
    }
    else {
        return 1;
    }
}

int isMoveable(Game* this, int x, int y) {
    if (this->map[x][y][0].type == BOMB || this->map[x][y][1].type == BOX || this->map[x][y][1].type == WALL) {
        return 0;
    }
    return 1;
}

int moveOneStep(int x, int y, int direction, int* new_x, int* new_y, int* frac_x, int* frac_y, int speed) {
    switch (direction) {
    case UP:    *frac_x -= speed; break; // Move up
    case DOWN:  *frac_x += speed; break; // Move down
    case LEFT:  *frac_y -= speed; break; // Move left
    case RIGHT: *frac_y += speed; break; // Move right
    }
    int ismove = 0;
    if (*frac_x > FRAC_RANGE) {
        *new_x = x + 1;
        *new_y = y;
        *frac_x -= 2 * FRAC_RANGE;
        ismove = 1;
    }
    else if (*frac_x < -FRAC_RANGE) {
        *new_x = x - 1;
        *new_y = y;
        *frac_x += 2 * FRAC_RANGE;
        ismove = 1;
    }
    else if (*frac_y > FRAC_RANGE) {
        *new_x = x;
        *new_y = y + 1;
        *frac_y -= 2 * FRAC_RANGE;
        ismove = 1;
    }
    else if (*frac_y < -FRAC_RANGE) {
        *new_x = x;
        *new_y = y - 1;
        *frac_y += 2 * FRAC_RANGE;
        ismove = 1;
    }
    else {
        *new_x = x;
        *new_y = y;

    }
    return ismove;
}

void placeBomb(Game* this) {
    if (this->player.bomb_cnt > 0 && this->map[this->player.x][this->player.y][0].type == EMPTY) {
        // Find an empty slot for a new bomb
        for (int i = 0; i < MAX_BOMB; i++) {
            if (this->bombs[i].timer <= 0) {  // Assuming a bomb's timer <= 0 means it's inactive
                this->bombs[i].x = this->player.x;
                this->bombs[i].y = this->player.y;
                this->bombs[i].timer = BOMB_TIMER + FIRE_TIMER; // Set a timer for the bomb
                this->bombs[i].range = this->player.bomb_range;
                this->map[this->player.x][this->player.y][0].type = BOMB;

                this->player.bomb_cnt--;
                break;
            }

        }
    }
}

void die(Game* this) {
    if (this->player.status != INVISIBLE) {
        this->player.life--;
        if (this->player.life == 0) {
            puts("Game Over!");
            exit(0); // End the game
        }
        this->map[this->player.x][this->player.y][1].type = EMPTY;
        this->player.x = this->player.y = 1;
        this->map[this->player.x][this->player.y][1].type = PLAYER;
        setInvisible(this, &this->player);
        this->timer = this->level_timer;
    }
}

void pollingPlayer(Game* this, int input) {
    if (input == SETBOMB) {
        placeBomb(this);
        return; // Early return as no movement is required
    }
    //deal with player status
    if (this->player.status == INVISIBLE) {
        this->player.timer--;
        if (this->player.timer == 0) {
            this->player.status = NORMAL;
        }
    }

    // Move player
    int newPlayerX = this->player.x;
    int newPlayerY = this->player.y;

    moveOneStep(this->player.x, this->player.y, input, &newPlayerX, &newPlayerY
        , &(this->player.frac_x), &(this->player.frac_y), this->player.speed);

    // Check if new position is valid
    if (isMoveable(this, newPlayerX, newPlayerY)) {
        // Check for collision with monsters
        if (this->map[newPlayerX][newPlayerY][1].type == MONSTER) {
            die(this);
            return;
        }
        if (this->map[newPlayerX][newPlayerY][0].type == TOOL) {
            int tool_index = this->map[newPlayerX][newPlayerY][0].id;
            switch (this->tools[tool_index].type) {
            case 0:this->player.life++; break;
            case 1:this->player.bomb_range++; break;
            case 2:this->player.bomb_cnt++; break;
            case 3:this->player.speed++; break;
            case 4:this->timer = this->timer + 30; break;
            }
            this->map[newPlayerX][newPlayerY][0].type = EMPTY;
            this->tools[tool_index].timer = 0;
        }

        // Update the player's position on the map
        this->map[this->player.x][this->player.y][1].type = EMPTY;
        this->player.x = newPlayerX;
        this->player.y = newPlayerY;
        this->map[this->player.x][this->player.y][1].type = PLAYER;
    }
}

int setInvisible(Game* this) {
    if (this->player.status == NORMAL) {
        this->player.status = INVISIBLE;
        this->player.timer = INVISIBLE_TIMER;
        return 1;
    }
    return 0;
}

void calculateNextMove(int x, int y, int direction, int* new_x, int* new_y) {
    switch (direction) {
    case UP: *new_x = x - 1; *new_y = y; break; // Move up
    case DOWN: *new_x = x + 1; *new_y = y; break; // Move down
    case LEFT: *new_x = x; *new_y = y - 1; break; // Move left
    case RIGHT: *new_x = x; *new_y = y + 1; break; // Move right
    }
}
int getFromDriection(Game* this, int direction) {
    int monster_from = 0;
    switch (direction) {
    case UP: monster_from = DOWN; break; // Move up
    case DOWN: monster_from = UP; break; // Move down
    case LEFT: monster_from = RIGHT; break; // Move left
    case RIGHT: monster_from = LEFT; break; // Move right
    }
    return monster_from;
}
int changeDirection(Game* this, int index) {
    int direction[4] = { 1,1,1,1 };
    //去掉monster来的方向
    int monster_from = getFromDriection(this, this->monsters[index].direction);
    getFromDriection(this, this->monsters[index].direction);
    direction[monster_from] = 0;
    for (int j = 0; j < 4; j++) {
        int newX = this->monsters[index].x;
        int newY = this->monsters[index].y;
        calculateNextMove(this->monsters[index].x, this->monsters[index].y, j, &newX, &newY);
        if (!isMoveableMonster(this, newX, newY)) {
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
    this->monsters[index].direction = new_direction;
    return new_direction;
}

void poolingMonster(Game* this) {
    for (int i = 0; i < MAX_MONSTER; i++) {
        if (this->monsters[i].valid) {
            int tmp1, tmp2;
            if (moveOneStep(this->monsters[i].x,this->monsters[i].y,
                            this->monsters[i].direction,&tmp1, &tmp2,
                            &(this->monsters[i].frac_x),&(this->monsters[i].frac_y),
                            this->monsters[i].speed)==1) {
                movMonsterToNextCell(this, i);
            }

        }
            
    }
}

int movMonsterToNextCell(Game* this, int index) {
    int i = index;
    //判断下一步是否有两个及以上方向可走
    int direct_able = 0;
    int monster_from = getFromDriection(this, this->monsters[index].direction);
    for (int j = 0; j < 4; j++) {
        int newX = this->monsters[i].x;
        int newY = this->monsters[i].y;
        switch (j) {
        case UP:newX--;break; // Move up
        case DOWN:newX++;break; // Move down
        case LEFT:newY--;break; // Move left
        case RIGHT:newY++;break; // Move right
        }
        if (isMoveableMonster(this, newX, newY) && monster_from != j) {
            direct_able++;
        }
    }
    //get last step from monster from
    int before_x;
    int before_y;
    calculateNextMove(this->monsters[i].x, this->monsters[i].y,
        monster_from, &before_x, &before_y);
    if (direct_able >= 2 && isMoveableMonster(this, before_x, before_y)) {
        this->monsters[i].direction = changeDirection(this, i);
    }

    int move = this->monsters[i].direction;
    int newMonsterX = this->monsters[i].x;
    int newMonsterY = this->monsters[i].y;
    calculateNextMove(this->monsters[i].x, this->monsters[i].y, move, &newMonsterX, &newMonsterY);

    // Check if new position is valid
    if (isMoveableMonster(this, newMonsterX, newMonsterY)) {

        // Check if monster encounters the player
        if (newMonsterX == this->player.x && newMonsterY == this->player.y) {
            die(this);
        }
        // Move the monster
        this->map[this->monsters[i].x][this->monsters[i].y][1].type = EMPTY;
        this->monsters[i].x = newMonsterX;
        this->monsters[i].y = newMonsterY;
        this->map[newMonsterX][newMonsterY][1].type = MONSTER;
        this->map[newMonsterX][newMonsterY][1].id = i;
    }
    else {
        // Change direction if the monster encounters a wall
        this->monsters[i].direction = changeDirection(this, i);

    }
}

int placeTool(Game* this, int x, int y) {
    for (int i = 0; i < MAX_TOOL; i++) {
        if (this->tools[i].timer == 0) {
            this->tools[i].x = x;
            this->tools[i].y = y;
            this->tools[i].type = rand() % 5;
            this->tools[i].timer = TOOL_TIMER;
            this->map[x][y][0].type = TOOL;
            this->map[x][y][0].id = i;
            return 1;
        }
    }
    return 0;
}

void clear(Game* this, int x, int y) {
    if (this->map[x][y][1].type == MONSTER) {
        int id = this->map[x][y][1].id;
        this->monster_num--;
        this->monsters[id].valid = 0;
        this->map[x][y][1].type = EMPTY;
    }

    // Check if the bomb encounters the player
    if (x == this->player.x && y == this->player.y) {
        die(this);
    }

    if (this->map[x][y][1].type == BOX) {
        // Kill the box
        this->map[x][y][1].type = EMPTY;
        // Generate a tool and place it on the map
        int generate_tool = rand() % 4;
        if (generate_tool == 1) {
            placeTool(this, x, y);
        }
    }
    if (this->map[x][y][1].type == BOSS) {
        this->boss.life--;
        if (this->boss.life == 0) {
            printf("You Win!!!!");
            exit(0);
        }
    }
}

void explode(Game* this, int x, int y) {
    this->map[x][y][2].type = FIRE;
    clear(this, x, y);
}

void setFire(Game* this, int x, int y) {
    this->map[x][y][2].type = FIRE;
}

void clearFire(Game* this, int x, int y) {
    this->map[x][y][2].type = EMPTY;
}

int IsDestroyable(Game* this, int x, int y) {
    if (this->map[x][y][1].type == WALL || this->map[x][y][0].type == BOMB) {
        return 0;
    }
    return 1;
}

void dealBomb(Game* this, int x, int y, int range, void (*job)(Game*, int, int)) {
    //改成汇编时，使用函数指针
    // deal in four directions
    job(this, x, y);
    for (int new_x = x + 1; new_x <= x + range; new_x++) {
        if (IsDestroyable(this, new_x, y)) {
            job(this, new_x, y);
        }
        else {
            break;
        }
    }
    for (int new_x = x - 1; new_x >= x - range; new_x--) {
        if (IsDestroyable(this, new_x, y)) {
            job(this, new_x, y);
        }
        else {
            break;
        }
    }
    for (int new_y = y + 1; new_y <= y + range; new_y++) {
        if (IsDestroyable(this, x, new_y)) {
            job(this, x, new_y);
        }
        else {
            break;
        }
    }
    for (int new_y = y - 1; new_y >= y - range; new_y--) {
        if (IsDestroyable(this, x, new_y)) {
            job(this, x, new_y);
        }
        else {
            break;
        }
    }
}

void poolingBomb(Game* this) {
    for (int i = 0; i < MAX_BOMB; i++) {
        int x = this->bombs[i].x;
        int y = this->bombs[i].y;
        int range = this->bombs[i].range;
        if (this->bombs[i].timer > 0) {
            this->bombs[i].timer--;
            if (this->bombs[i].timer > FIRE_TIMER) {
                continue;
            }
            else if (this->bombs[i].timer == FIRE_TIMER) {
                // Explode the bomb
                this->map[x][y][0].type = FIRE;
                dealBomb(this, x, y, range, explode);
                this->player.bomb_cnt++;
            }
            else if (this->bombs[i].timer > 0) {
                this->map[x][y][0].type = FIRE;
                dealBomb(this, x, y, range, setFire);
            }
            else if (this->bombs[i].timer == 0) {
                this->map[x][y][0].type = EMPTY;
                dealBomb(this, x, y, range, clearFire);
            }
        }
    }
}

void poolingTool(Game* this) {
    for (int i = 0; i < MAX_TOOL; i++) {
        if (this->tools[i].timer != 0) {
            this->tools[i].timer--;
            if (this->tools[i].timer == 0) {
                // Clear the tool
                this->map[this->tools[i].x][this->tools[i].y][0].type = EMPTY;
            }
        }
    }
}

void preAttack(Game* this, int x, int y) {
    this->map[x][y][2].type = ATTACK;
}
void makeAttack(Game* this, int x, int y) {
    this->map[x][y][2].type = BLUEFIRE;
    clear(this, x, y);
}
void makeDrop(Game* this, int x, int y) {
    clear(this, x, y);
}
void dealAttack(Game* this, int x, int y, void (*job)(Game*, int, int)) {
    for (int i = x - 1; i <= x + 1; i++) {
        for (int j = y - 1; j <= y + 1; j++) {
            if (this->map[i][j][1].type != WALL) {
                job(this, i, j);
            }
        }
    }
}

void poolingAttack(Game* this) {
    for (int i = 0; i < MAX_ATTACK; i++) {
        if (this->attacks[i].time > 0) {
            this->attacks[i].time--;
            if (this->attacks[i].time > ATTACK_TIME) {
                dealAttack(this, this->attacks[i].x, this->attacks[i].y, preAttack);
            }
            else if (this->attacks[i].time > 0) {
                dealAttack(this, this->attacks[i].x, this->attacks[i].y, makeAttack);
            }
            else {
                dealAttack(this, this->attacks[i].x, this->attacks[i].y, clearFire);
            }
        }
    }
}

void bossAttack(Game* this) {
    int x = this->player.x;
    int y = this->player.y;
    int id;
    for (int i = 0; i < MAX_ATTACK; i++) {
        if (this->attacks[i].time == 0) {
            id = i;
            this->attacks[i].x = x;
            this->attacks[i].y = y;
            this->attacks[i].time = PRE_ATTACK_TIME + ATTACK_TIME;
            break;
        }
    }
}

void bossDrop(Game* this) {
    this->boss.in_map = 1;
    dealAttack(this, this->boss.x, this->boss.y, makeDrop);
    this->map[this->boss.x][this->boss.y][1].type = BOSS;
}

void poolingBoss(Game* this) {
    if (this->boss.in_map) {
        this->boss.cool_time--;
        if (this->boss.cool_time == 0) {
            this->boss.in_map = 0;
            this->boss.sky_time = SKY_TIME;
            this->map[this->boss.x][this->boss.y][1].type = EMPTY;
        }
    }
    else {
        if (this->boss.sky_time > 0) {
            this->boss.sky_time--;
            if (this->boss.sky_time == 0) {
                this->boss.pre_drop_time = PRE_DROP_TIME;
                this->boss.x = this->player.x;
                this->boss.y = this->player.y;
            }
            else if (this->boss.sky_time % ATTACK_FREQ == 0) {
                bossAttack(this);
            }
        }
        else {
            if (this->boss.pre_drop_time > 0) {
                this->boss.pre_drop_time--;
                if (this->boss.pre_drop_time == 0) {
                    dealAttack(this, this->boss.x, this->boss.y, clearFire);
                    bossDrop(this);
                    this->boss.cool_time = COOL_TIME;
                }
                else {
                    dealAttack(this, this->boss.x, this->boss.y, preAttack);
                }
            }
        }
    }
}

void poolingSuccess(Game* this) {
    if (this->monster_num == 0) {
        puts("You Win!");
        this->level++;
        level_init(this);
    }
}

void archive(Game* this) {
    FILE* file;
    file = fopen("save.bb", "wb");
    fwrite(this, sizeof(struct Game), 1, file);
    fclose(file);
}
void read(Game* this) {
    FILE* file;
    file = fopen("save.bb", "rb");
    fread(this, sizeof(Game), 1, file);
    fclose(file);
}

int ReadKey() {
    //char key_table = {'w','a'};
    short ret_value;
    ret_value = GetAsyncKeyState('W');
    if (ret_value & 0x0001) { return UP; }
    ret_value = GetAsyncKeyState('A');
    if (ret_value & 0x0001) { return LEFT; }
    ret_value = GetAsyncKeyState('S');
    if (ret_value & 0x0001) { return DOWN; }
    ret_value = GetAsyncKeyState('D');
    if (ret_value & 0x0001) { return RIGHT; }
    ret_value = GetAsyncKeyState('B');
    if (ret_value & 0x0001) { return SETBOMB; }
    return -1;  //没有任何输入
}

int main() {
    setbuf(stdout, NULL);
    Game game;
    initGame(&game);
    srand(time(NULL));

    while (1) {
        draw(&game);
        printf("Move (WASD) or Place Bomb (B): ");
        //char input = getchar();
        char input = ReadKey();
        if (input != -1) {
            pollingPlayer(&game, input);
        }
        poolingMonster(&game);
        poolingBomb(&game);
        poolingTool(&game);
        poolingSuccess(&game);
        poolingBoss(&game);
        poolingAttack(&game);
        // Additional logic here for bomb timer countdown and explosion
        Sleep(100);
        system("cls"); // or system("cls") on Windows
    }
    return 0;
}