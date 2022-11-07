#include "function.h"
struct location {
	int x;
	int y;
};
struct accurate_location {
	double x;
	double y;
};
struct vel
{
	int v = 0;
	int theta = 0;
};
struct control
{
	int x;
	int theta;
};
/*****************************************************************/
//控制台
class control_desktop {
public:
	double t = 0;//当前时间
	flight* flght_list[2];//飞机列表
	bool maps[10][map_height][map_width] = { 0 };//地图列表
	int map_type = 0;//当前的地图类型
	bullet* bullet_list[max_bullet_num];//全局子弹表
	exp_bag* exp_bag_list[max_bullet_num];//全局经验包表
	bullet_and_gun_bag* b_and_g_list[max_bullet_num];//全局功能包表
};
control_desktop desk_top;
/***********************************************************/
//飞机类
class flight
{
public:
	int id;//飞机编号
	int max_blood = default_blood;
	int current_blood = default_blood;
	int square = flight_square;//贴图的半径
	location locate;//像素位置
	accurate_location ac_locate;//准确位置
	vel v;//当前速度
	int level = default_level;//当前等级
	int exp = 0;//当前经验值
	int attack = default_attack;//伤害
	int attack_frequncy = default_attack_frequncy;//攻击频率
	int calibre = default_calibre;//口径
	int bullets = 0;//子弹类型
	int num_bullet = default_num_bullet;//子弹数
	gun* guns = nullptr;//武器类型
};
//飞机移动
bool flight_move(flight& des,int chang_x,int change_theata) {
	des.v.theta= (des.v.theta + change_theata) % 360;
	double change_x = (des.v.v * chang_x / fps) * cos(des.v.theta / (2 * 3.1415926));
	double change_y = (des.v.v * chang_x / fps) * sin(des.v.theta / (2 * 3.1415926));
	des.ac_locate.x += change_x;
	des.ac_locate.y += change_y;
	//得出准确位置
	if (des.ac_locate.x > des.locate.x) {
		//如果前进
		for (; des.locate.x < des.ac_locate.x; des.locate.x++) {
		//逐像素递进，直到碰壁，或者结束；
			if (!judge_location(des.locate, des.square)) {
				des.locate.x -= 1;
				des.ac_locate.x = des.locate.x;//碰壁则将准确位置返回为最后位置
				break;
			}
		}
	}
	else {
		for (; des.locate.x > des.ac_locate.x; des.locate.x--) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.x += 1;
				des.ac_locate.x = des.locate.x;
				break;
			}
		}
	}
	if (des.ac_locate.y > des.locate.y) {
		for (; des.locate.y< des.ac_locate.y; des.locate.y++) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.y -= 1;
				des.ac_locate.y = des.locate.y;
				break;
			}
		}
	}
	else {
		for (; des.locate.y > des.ac_locate.y; des.locate.y--) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.y+= 1;
				des.ac_locate.y = des.locate.y;
				break;
			}
		}
	}
	return true;
}
//飞机射击
bool flight_shoot(flight& des) {
	bullet* new_bullet = bullet_initial(des.id,des.bullets,des.locate.x, des.locate.y,des.ac_locate.x,des.ac_locate.y, des.v.theta);
	for (int i = 0; i < default_num_bullet; i++) {
		if (desk_top.bullet_list[i] == nullptr) {
			desk_top.bullet_list[i]= new_bullet;
			break;
		}
	}

	//如果不是默认子弹，则子弹数减少
	if (des.bullets != default_bullet) {
		des.num_bullet--;
		//如果子弹数为零则切换回默认子弹
		if (des.num_bullet == 0) {
			des.bullets = default_bullet;
			des.num_bullet = default_num_bullet;
		}
	}
	return true;
}
//飞机升级
bool flight_add_exp(flight& des, int des_exp) {
	des.exp += des_exp;
	while (des.exp > leavel_exp_list[des.level]) {
		des.level++;
		des.max_blood = leavel_hp_list[des.level];
		des.current_blood += 50;
	}
	return true;
}
/***************************************************/
//子弹类
class bullet
{
public:
	int belonging;
	vel v;
	int square=default_bullet_square;
	location locate;
	accurate_location ac_locate;
	int attack_num=default_attack_num;
	int aoe_rate=default_aoerate;
	int types = 0;
};
bullet* bullet_initial(int belonging,int type, int x, int y,double ac_x,double ac_y,int theata) {
	bullet* des= (bullet*)malloc(sizeof(bullet));
	des->belonging = belonging;
	des->types = type;
	des->v.v = default_vel;
	des->v.theta = theata;
	des->locate.x = x;
	des->locate.y = y;
	des->ac_locate.x = ac_x;
	des->ac_locate.y = ac_y;
	return des;
}
bool bullet_move(bullet& des) {
	double change_x = (des.v.v / fps) * cos(des.v.theta / (2 * 3.1415926));
	double change_y = (des.v.v / fps) * sin(des.v.theta / (2 * 3.1415926));
	des.ac_locate.x += change_x;
	des.ac_locate.y += change_y;
	if (des.ac_locate.x > des.locate.x) {
		for (; des.locate.x < des.ac_locate.x; des.locate.x++) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.x -= 1;
				des.ac_locate.x = des.locate.x;
				return false;
			}
		}
	}
	else {
		for (; des.locate.x > des.ac_locate.x; des.locate.x--) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.x += 1;
				des.ac_locate.x = des.locate.x;
				return false;
			}
		}
	}
	if (des.ac_locate.y > des.locate.y) {
		for (; des.locate.y < des.ac_locate.y; des.locate.y++) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.y -= 1;
				des.ac_locate.y = des.locate.y;
				return false;
			}
		}
	}
	else {
		for (; des.locate.y > des.ac_locate.y; des.locate.y--) {
			if (!judge_location(des.locate, des.square)) {
				des.locate.y += 1;
				des.ac_locate.y = des.locate.y;
				return false;
			}
		}
	}
	return true;
}
bool bullet_destory(bullet& bullet) {
	free(&bullet);
	return true;
}
/*******************************************************/
class gun
{
public:
};
/*******************************************/
class exp_bag {
public:
	double t = 0;
	int exp = default_exp;
	int max_blood = default_expbag_blood;
	int current_blood = default_expbag_blood;
	int square = default_bag_square;
	location locate;
	int rate=1;
	int final_touch = -1;
};
exp_bag* exp_bag_initial(int rate, int x, int y) {
	exp_bag* des = (exp_bag*)malloc(sizeof(exp_bag));
	des->rate = rate;
	des->max_blood = des->max_blood * rate;
	des->current_blood = des->max_blood;
	des->exp = des->exp * rate;
	des->locate.x = x;
	des->locate.y = y;
	return des;
}
bool exp_bag_destoyied(exp_bag& des) {
	free(&des);
	return true;
}
/***********************************************************/
class bullet_and_gun_bag {
public:
	double t = 0;
	int square = default_bag_square;
	location locate;
	bool touchable = false;
	int types;
};
bullet_and_gun_bag* bullet_and_gun_bag_initial(int type, int x, int y) {
	bullet_and_gun_bag* des = (bullet_and_gun_bag*)malloc(sizeof(bullet_and_gun_bag));
	des->types = type;
	des->locate.x = x;
	des->locate.y = y;
	return des;
}
bool bullet_and_gun_bag_destoyied(bullet_and_gun_bag& des) {
	free(&des);
	return true;
}
/***********************************************************/
bool judge_location(location& des, int square) {
	int left_boundary = des.x > square ? des.x - square : 0;
	int right_boundary = des.x + square < map_width ? des.x + square : map_width;
	int top_boundary = des.y > square ? des.y - square : 0;
	int down_boundary = des.y + square < map_height ? des.y + square : map_height;
	for (int j = top_boundary; j <= down_boundary; j++) {
		for (int k = left_boundary; k <= right_boundary; k++) {
			if (desk_top.maps[desk_top.map_type][j][k] && (j - des.y) * (j - des.y) + (k - des.x) * (k - des.x) < square * square)
				return false;
		}
	}
	return true;
}
bool judge_touch_flight_bullet() {
	for (int i = 0; i < 2; i++) {
		for (int j = 0; j <default_num_bullet; j++) {
			if (desk_top.bullet_list[j] == nullptr)
				continue;
			int x = desk_top.bullet_list[j]->ac_locate.x - desk_top.flght_list[i]->ac_locate.x;
			int y = desk_top.bullet_list[j]->ac_locate.y - desk_top.flght_list[i]->ac_locate.y;
			int square = desk_top.bullet_list[j]->square + desk_top.flght_list[i]->square;
			if (x * x + y * y < square * square) {
				desk_top.flght_list[i]->current_blood -= desk_top.bullet_list[i]->attack_num;
				bullet_destory(*desk_top.bullet_list[i]);
				desk_top.bullet_list[i] = nullptr;
			}
		}
	}
	return true;
}
bool judge_touch_flight_b_and_g() {
	for (int i = 0; i < 2; i++) {
		for (int j = 0; j < default_num_bullet; j++) {
			if (desk_top.bullet_list[j] == nullptr)
				continue;
			int x = desk_top.b_and_g_list[j]->locate.x - desk_top.flght_list[i]->ac_locate.x;
			int y = desk_top.b_and_g_list[j]->locate.y - desk_top.flght_list[i]->ac_locate.y;
			int square = desk_top.b_and_g_list[j]->square + desk_top.flght_list[i]->square;
			if (x * x + y * y < square * square) {
				desk_top.flght_list[i]->bullets = desk_top.b_and_g_list[j]->types;
				bullet_and_gun_bag_destoyied(*desk_top.b_and_g_list[j]);
				desk_top.b_and_g_list[j] = nullptr;
			}
		}
	}
	return false;
}
bool judge_touch_bullet_exp_bag() {
	for (int i = 0; i < default_num_bullet; i++) {
		for (int j = 0; j < default_num_bullet; j++) {
			if (desk_top.bullet_list[j] == nullptr||desk_top.b_and_g_list[i]==nullptr)
				continue;
			int x = desk_top.bullet_list[j]->locate.x - desk_top.exp_bag_list[i]->locate.x;
			int y = desk_top.bullet_list[j]->locate.y - desk_top.exp_bag_list[i]->locate.y;
			int square = desk_top.b_and_g_list[j]->square + desk_top.exp_bag_list[i]->square;
			if (x * x + y * y < square * square) {
				desk_top.exp_bag_list[i]->final_touch = desk_top.bullet_list[j]->belonging;
				desk_top.exp_bag_list[i]->current_blood -= desk_top.bullet_list[j]->attack_num;
				bullet_destory(*desk_top.bullet_list[j]);
				desk_top.bullet_list[j] = nullptr;
			}
		}
	}
	return false;
}
location* rand_createbag() {
	location* tmp = (location*)malloc(sizeof(location));
	tmp->x = rand() % map_width;
	tmp->y= rand() % map_height;
	while (!judge_location(*tmp, default_bag_square)) {
		tmp->x = rand() % map_width;
		tmp->y = rand() % map_height;
	}
	return tmp;
}
/**********************************************************/
void update_move() {
	for (int i = 0; i < default_num_bullet; i++) {
		if (desk_top.bullet_list[i] == nullptr)
			continue;
		if (!bullet_move(*desk_top.bullet_list[i])) {
			bullet_destory(*desk_top.bullet_list[i]);
			desk_top.bullet_list[i] = nullptr;
		}
	}


	int change_x = rand() % 10;
	int	change_theta=rand()%10;
	flight_move(*desk_top.flght_list[0], change_x, change_theta);
	change_x = rand() % 10;
	change_theta = rand() % 10;
	flight_move(*desk_top.flght_list[1], change_x, change_theta);

	for (int i = 0; i < default_num_bullet; i++) {
		if (desk_top.b_and_g_list[i] == nullptr)
			continue;
		desk_top.b_and_g_list[i]->t += 1 / fps;
		if (desk_top.b_and_g_list[i]->t > default_bag_pre) {
			desk_top.b_and_g_list[i]->touchable = true;
			if (desk_top.b_and_g_list[i]->t > default_bag_limit) {
				bullet_and_gun_bag_destoyied(*desk_top.b_and_g_list[i]);
				desk_top.b_and_g_list[i] = nullptr;
			}
		}
	}

	for (int i = 0; i < default_num_bullet; i++) {
		if (desk_top.exp_bag_list[i] == nullptr)
			continue;
		desk_top.b_and_g_list[i]->t += 1 / fps;
		if (desk_top.exp_bag_list[i]->t > default_bag_limit) {
			exp_bag_destoyied(*desk_top.exp_bag_list[i]);
			desk_top.exp_bag_list[i] = nullptr;
		}
		else {
			if (desk_top.exp_bag_list[i]->current_blood <= 0) {
				flight_add_exp(*desk_top.flght_list[desk_top.exp_bag_list[i]->final_touch], desk_top.exp_bag_list[i]->exp);
				exp_bag_destoyied(*desk_top.exp_bag_list[i]);
				desk_top.exp_bag_list[i] = nullptr;
			}
		}
	}
}
void judge_touch() {
	judge_touch_flight_bullet();
	judge_touch_bullet_exp_bag();
	judge_touch_flight_b_and_g;
}
void create_new(){
	int flag = rand() % 2;
	if (flag) {
		flight_shoot(*desk_top.flght_list[0]);
	}
	flag = rand() % 2;
	if (flag) {
		flight_shoot(*desk_top.flght_list[1]);
	}
	flag = rand() % 1000;
	if (flag <= create_exp_bag_rate) {
		location* tmp = rand_createbag();
		exp_bag* new_exp_bag=exp_bag_initial(rand() % exp_bag_types, tmp->x, tmp->y);
		free(tmp);
		for (int i = 0; i < default_num_bullet; i++) {
			if (desk_top.exp_bag_list[i] == nullptr) {
				desk_top.exp_bag_list[i] = new_exp_bag;
				break;
			}
		}
	}
	flag = rand() % 1000;
	if (flag <= create_bullet_bag_rate) {
		location* tmp = rand_createbag();
		bullet_and_gun_bag* new_bullet_bag = bullet_and_gun_bag_initial(rand() % bullet_bag_types, tmp->x, tmp->y);
		free(tmp);
		for (int i = 0; i < default_num_bullet; i++) {
			if (desk_top.b_and_g_list[i] == nullptr) {
				desk_top.b_and_g_list[i] = new_bullet_bag;
				break;
			}
		}
	}
}
/*********************************************************/
int main() {
	return 0;
}