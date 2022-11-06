#include <iostream>
#include<stdlib.h>
#include<math.h>
#define map_height 400
#define map_width 400
#define fps 30.0
#define max_bullet_num 512
/**************************************/
#define default_blood 200
#define default_level 1
#define default_attack 20
#define default_attack_frequncy 1
#define default_calibre 1
#define flight_square 10
#define default_bullet 0
#define default_num_bullet 50
/****************************************/
#define default_bullet_square 2
#define default_attack_num 10
#define default_aoerate 0.5
#define default_vel 1
/****************************************/
#define default_expbag_blood 100
#define default_bag_square 10
#define default_bag_pre 2
#define default_bag_limit 20
#define default_exp 20
#define create_exp_bag_rate 1
#define exp_bag_types 5
#define create_bullet_bag_rate 1
#define bullet_bag_types 5
/*************************************************/
class bullet;
class control_desktop;
class gun;
class flight;
class exp_bag;
class bullet_and_gun_bag;
struct vel;
struct control;
struct location;
struct accurate_location;

using namespace std;
int leavel_exp_list[] = { 50, 75, 100, 100, 100, 125,125,10000000000000000};
int leavel_hp_list[] = { 100,150,200,250,300 };
bool judge_location(location& des, int square);
bullet* bullet_initial(int belonging, int type, int x, int y, double ac_x, double ac_y, int theata);
