## 类
### 飞机 AEROCRAFT
#### 属性
- ID dd dwID  
  > ID为零表示并没有初始化位置，或是不存在，下同。值得注意的是必须在声明时初始化，否则在_GetaPos里可能会出问题
- 当前生命值 dd dwHP
- 最大生命值 dd dwMaxHP
- 当前半径 dd dwRadius
- 当前朝向 dd dwForward
- 当前位置 POS stNowPos
- 当前等级 dd dwLevel
- 当前经验 dd dwExp
- 攻击力 dd dwAtk
- 攻速 dd dwAtf
- 口径 dd dwCaliber
- 武器类型 dd dwWeaponType
- 弹药类型 dd dwAmmunition
- 图片句柄 dd hBmp
- 绘图句柄 dd hDC
- 弹药速度 dd dwBulletSpeed
- 此刻希望的位移 dd dwNxt  
  > 因为每帧才走一次，所以收到键盘读入以后会记录下来，并在帧中进行移动。0表示不变。1234分别为上下左右。移动后归零。
- 当前速度 dd dwSpeed  
  > 表示每1000帧移动的像素
- 距离玩家最后一次发射弹药的帧数 dd dwFireStamp

#### 方法
- 移动 _AerocraftMove  
  > 描述：单纯延当前方向移动，在里面判断逻辑  
  > 输入：offset AEROCRAFT(目标飞机结构体下标)  
  > 输出：NULL  
- 更改朝向 _AerocraftVeer
  > 无输入，自动给两个飞机更改朝向，并置零dwNxt
- 发射子弹 _AerocraftFire
  > 描述：射出子弹  
  > 输入：飞机地址指针 dd  
  > 输出：eax子弹地址指针  
- 更改武器 _AerocraftChangeWeapon
- 更改弹药 _AerocraftChangeAmmunition
- 升级 _AerocraftLevelUp
- 获得经验 _AerocraftGainExp
  > 描述：获得经验值，并且返回是否升级。返回值保存在eax中。升级返回1，否则返回0  
  > 输入：飞机的地址指针dd，获得的经验数目dd  
  > 输出：eax  
- 更改当前生命 _AerocraftChangeNowHP
  > 描述：更改血量，将当前血量直接加上输入。若超过则设置成满血。不进行归零的逻辑判断  
  > 输入：飞机地址指针dd，有符号数dd  
  > 输出：NULL
- 更改最大生命值 _AerocraftChangeMaxNowHP
  > 描述：输入输出同上
- 更改攻击力 _AerocraftChangeAtk
  > 描述：输入输出同上
- 更改攻速 _AerocraftChangeAtf
- 更改口径 _AerocraftChangeCaliber
- 更改武器 _AerocraftChangeBullet
   >输入：飞机的指针 ，武器的种类type
- 初始化 _AerocraftInit 
  > 描述：无输入，自动给两个实体赋各种初值  
输入：NULL  
输出：NULL
- 析构 _AerocraftDestroy


---

### 子弹 BULLET
#### 属性
- id dd dwID  
该位未被占用时为0，下同
- 归属飞行器ID dd dwAerocraftID
- 飞行速度 dd dwSpeed
- 飞行角度 dd dwForward
- 半径 dd dwRadius
- 当前位置 POS stNowPos
- 伤害 dd dwAtk
- 绘图句柄 dd hDC

#### 方法
- 移动 _BulletMov
- 初始化 _BulletInit   
  > 描述：在子弹列表之中寻找空位，分配给新的子弹，其ID为从一开始的数，返回分配的地址。取得子弹类型对应的hDC  
  > 输入：子弹所属的飞机指针  
  > 输出：子弹类的指针
- 析构 _BulletDestroy  
  > 描述：将所传入的子弹ID置为0，设置为无效数据  
  > 输入：子弹地址指针 dd  
  > 输出：NULL
- 判断命中 _BulletHitCheck
  > 描述：依次调用三个判断函数，命中后析构子弹类并跳出。若命中输出为1，否则为0，保存在eax中  
  > 输入：子弹地址指针  
  > 输出：eax
- 判断是否命中玩家并进行后续操作 _BulletHitPlayer
  > 描述：首先判断是否命中。若未命中返回0，否则返回1.命中的话，更改玩家血量并酌情结束游戏。  
  > 输入：offset BULLET  
  > 输出：eax
- 判断是否命中经验包并进行后续操作 _BulletHitExp
  > 描述：首先判断是否命中。若未命中返回0，命中返回1。命中的话，更改经验包血量，然后判断是否击杀经验包。若击杀经验包，为子弹发出者进行加经验或升级操作。(这里我认为升级操作在加经验函数内进行判断，如果不是 要记得改)  
  > 输入：offset BULLET  
  > 输出：eax
- 判断是否命中墙体并进行后续操作 _BulletHitWall
  > 基本同上
- 移动子弹 _BulletMove
  > 描述：按照子弹属性进行移动  
  > 输入：子弹地址指针 dd  
  > 输出：NULL
---

### 经验包
#### 属性
- id dd dwID
- 当前生命值 dd dwHP
- 类型编号 dd dwType
- 当前位置 POS stNowPos
- 绘图句柄 dd hDC

#### 方法
- 初始化 _ExpPackInit
  > 描述：在经验包列表之中寻找空位，分配给新的经验包，其ID为在表中的序号，返回分配的地址。取得Exp对应的hDC  
  > 输入：经验包的类型  dd   
  > 输出：经验包的指针
- 析构 _ExpPackDestroy
  > 描述：将所传入的经验包ID置为0，设置为无效数据  
  > 输入：经验包指针  dd  
  > 输出：null
- 被子弹击中 _ExpPackAttacked
  > 描述：扣除经验包一定的血量  
  > 输入：经验包指针  dd；扣除血量 dd  
  > 输出：eax（当前血量）
---

### 武器包
#### 属性
- id dd dwID
- 类型编号 dd dwType 
- 空间坐标 POS stNowPos
- 位图句柄 dd hBmp
- 绘图句柄 dd hDC
- 武器类型	dd	dwType

#### 方法
- 初始化 _BulletPackInit
- 析构 _BulletPackDestroy
- 玩家是否与武器包相撞	_PlayerHitBulletPack
 > 判断飞机是否与武器包相撞，输出撞eax = 1, eax = 0  
 > 输入：ptr 玩家@lpPlayer  
 > 输出：eax  

### 障碍物Barrier
#### 属性 
- 空间坐标 POS stNowPos
- 位图句柄 dd hBmp
- 绘图句柄 dd hDC
- 障碍物半径	dd	dwRadius
- ID  ddID

#### 方法
- 初始化 _BulletBarrierInit
- 玩家是否与障碍物相撞	_PlayerHitBarrier
 > 判断飞机是否与障碍物相撞，输出撞eax = 1, eax = 0  
 > 输入：ptr 玩家@lpPlayer  
 > 输出：eax  
- 子弹是否与障碍物相撞	_BulletHitBarrier
 > 判断子弹是否与障碍物相撞，输出撞eax = 1, eax = 0  
 > 输入：ptr 子弹@lpBullet  
 > 输出：eax  
- 包是否与障碍物相撞	_PackHitBarrier
 > 判断包是否与障碍物相撞，输出撞eax = 1, eax = 0  
 > 输入：位置 Pos  ，半径 dwRadius  
 > 输出：eax

### 游戏逻辑控制类 Main
#### 属性
- 计时器 dd dwTimer
  > 这个计时器用来维护经验包武器包的生成；玩家发射弹药；
- 距离最后一次生成武器包的帧数 dd dwWeaponStamp
- 距离最后一次生成经验包的帧数 dd dwExpStamp

#### 方法
- 初始化 _MainInit  
  > 描述：  
&emsp;&emsp;初始化属性数值  
&emsp;&emsp;设置时间种子  
&emsp;&emsp;初始化经验包武器包生成计时器  
&emsp;&emsp;调用玩家初始化函数  
输入：NULL  
输出：NULL  

- 响应键盘输入 _MainKeyBoard  
  > 描述：  
  > &emsp;&emsp;更新AEROCRAFT类的nxt  
  > 输入：char:dd  
  > 输出：NULL

- 进行一帧运算 _MainFrame
  > &emsp;描述：


- 控制玩家发射弹药 _MainFire  
  > 描述：  
&emsp;&emsp;根据计时器、攻速和时间戳依次判断两个玩家该时刻是否应该发射弹药，并酌情发射弹药，发射后更新时间戳  
输入：NULL  
输出：NULL  

- 控制生成经验包 _MainGenerateExp    
  > 描述：  
&emsp;根据计时器和时间戳判断是否需要生成经验包。若生成则生成。生成后更新时间戳。  
输入：NULL  
输出：NULL

- 控制生成武器包 _MainGenerateWeapon  
  > 描述：  
&emsp;&emsp;根据计时器和时间戳判断是否需要生成武器包。若生成则生成。生成后更新时间戳。  
输入：NULL  
输出：NULL  

---

### 画面显示控制类 _ShowMaker
> 负责显示画面和维护窗口相关的操作。
#### 属性
- 背景图片的位图句柄 dd hBmpBack
- 背景图片的绘图句柄 dd hDCBack
- 子弹类型0的绘图句柄 dd hBulletDC0
- 经验包类型1的绘图句柄 dd hExpDC1
- 经验包类型2的绘图句柄 dd hExpDC2
- 经验包类型3的绘图句柄 dd hExpDC3
- dd hBulletBmp0
- dd hExpBmp1
- dd hExpBmp2
- dd hExpBmp3
- dd hBarrierBmp
- dd hBarrierDC
#### 方法
- 重绘图像 _ShowMakerPaint
- 初始化很多句柄并第一次显示图像 _ShowMakerPaint
- 初始化 _ShowMakerInit
- 析构 _ShowMakerDestroy
- 绘制障碍物 _ShowMakerShowBarrier

---

## 会用到的工具函数与类

### 取模函数 _mod
  > &emsp;&emsp;描述：输入无符号数x, y, 返回x % y在eax中  
  > &emsp;&emsp;输入：x:dd, y:dd  
  > &emsp;&emsp;输出：eax

### 浮点数比较函数 _fcmp
  > &emsp;&emsp;描述：传入两个real8，依次为x，y，若x>y则返回1，<返回-1，严格等于返回0，返回值在eax中  
  > &emsp;&emsp;输入：x:real8, y:real8  
  > &emsp;&emsp;输出：eax

### 浮点数相等判断函数 _fequ
  > &emsp;&emsp;描述：传入两个real8分别为x, y, 相等返回1，不相等返回0，异常返回-1，返回值保存在eax中。  
  > &emsp;&emsp;输入：x:real8, y:real8  
  > &emsp;&emsp;输出：eax

### 计算两点距离 _Getdis
  > &emsp;&emsp;描述：传入两个POS，返回两点距离，返回值保存在st(0)   
  > &emsp;&emsp;输入：POS, POS  
  > &emsp;&emsp;输出：st(0):real8

### 随机数生成器类 Rand
#### 属性
自己看着加，加完了在注释里写一下我写文档里。
#### 方法
- 用当前时间设置随机化种子 _RandSetSeed  
  > &emsp;&emsp;描述：初始化随机数种子，若输入eax为0，则用时间填充  
&emsp;&emsp;输入：NULL  
&emsp;&emsp;输出：NULL

- 得到一个随机数 _RandGet  
  > &emsp;&emsp;描述：输入一个有符号数存在eax中，返回一个[0, eax)间的随机数，最多到32767(2^15-1)  
&emsp;&emsp;输入：eax(dd)  
&emsp;&emsp;输出：eax(dd)

### 延给定方向和长度移动函数 _BitMove
  > &emsp;&emsp;描述：输入长度方向角和当前位置指针，计算延该方向移动输入长度后的新坐标，并修改当前位置  
&emsp;&emsp;输入：len(dd, 10\*长度), dir(dd, 方向角\*100), offset POS(dd, 当前位置指针)  
&emsp;&emsp;输出：NULL

### 判断两个圆形是否相交 _CheckCircleCross  
  > &emsp;&emsp;描述：结果保存在eax中。若相交则为0， 否则为1。  
&emsp;&emsp;输入：（坐标1，半径1，坐标2，半径2）(POS, dd, POS, dd)  
&emsp;&emsp;输出：eax(0 / 1)

### 判断某个圆形是否与边界相交或超出边界 _CheckCircleEdge  
  > &emsp;&emsp;描述：结果保存在eax中。若相交或超出则为0，否则为1。  
&emsp;&emsp;输入：（坐标，半径）(POS, dd)  
&emsp;&emsp;输出：eax

### 返回一个可用坐标 _GetaPos
&emsp;&emsp;描述：输入一个半径。该函数扫描所有实体，返回一个点，保证以该点为圆心，输入为半径的圆与任意实体不相交。若无可用坐标，则返回寄存器全部为0  
  > &emsp;&emsp;输入：eax(dd, 半径)  
&emsp;&emsp;输出：eax(dd, X), ebx(dd, Y)

### 像素位置类 INTPOS
#### 属性
- x坐标 dd dwX
- y坐标 dd dwY

### 位置类 POS
#### 属性
- x坐标 REAL fX
- y坐标 REAL fY


---

# 备忘的杂项

&emsp;&emsp;按理说是要有一个游戏内教程的。但是呢，如果把教程放在游戏内的话还要做界面。所以我倾向于把教程写到文档里

---

&emsp;&emsp;emmm，我觉得很有必要写一个double类和int类，方便各种计算。int其实还好，浮点数各种计算是真的烦。一点点来吧。  
&emsp;&emsp;首先要指定一个这种类的标准。

---

&emsp;&emsp;总结一下现在的提升系统。

1. 等级系统，升级时提供进化选项
2. 武器包系统，拾取后改变炮口数量、朝向
3. 弹药包系统，拾取后改变发射弹药类型

---

&emsp;&emsp;要不要设置几个障碍物？感觉有障碍物的话可玩性会强一点。随机生成？设置多个地图？

---

&emsp;&emsp;对于如何处理多种类型子弹的问题，我们可以预先开一个表，以类型编号为key，(伤害, 速度, 方向……)的几元组为value。每帧扫描子弹列表，通过子弹类记录的类型属性查找相关参数，来计算下一帧的情况。

&emsp;&emsp;怎样实现动态的子弹数量？我们可以预先申请出一个表，开辟出，比如说，512枚子弹会占用的空间。然后每一项用一位记录该项是否启用。新建子弹的过程是，扫描空间，遇到第一个未占用子弹……；销毁子弹只需要将对应子弹标志位置零即可。(有点像操作系统里那个叫什么来着的那个，位什么表)

---

&emsp;&emsp;Qt大作业的惨痛教训告诉我们，如果可以的话，尽量不要抱着“先搞出一版简单的，再在此基础上升级”这种想法开展项目。因为在升级的过程中难免会需要对之前的代码做出相应的调整。这种调整在逻辑上并不直观，因此很容易出错。这次我们不妨试着抱着破釜沉舟的勇气，想做什么一开始就全弄进去。

---

&emsp;&emsp;做一个什么样的升级系统比较好呢？我想弄出一点多样性来。干脆弄成Rouglike的形式吧！同时我还想给予玩家“选择”，这样可以保证玩家真正关注了进化的结果。

&emsp;&emsp;那我提出这样一种升级系统：地图上随机生成几种经验包，每种经验包有相应的血量和经验，造成致命伤害的玩家获得其经验。

&emsp;&emsp;每个等级的经验值升满后，进入下一个等级（等级可以设置一个上限）。升级的同时弹出两个进化选项。玩家可以二选一进行进化。需要弄一个具有先后关系的进化树吗？感觉不需要，因为这不是玩家能够任意选择的，所以玩家的体验并不友好，而且实现起来有点复杂。

&emsp;&emsp;也不一定要两个选项。也可以用数字键然后提供多个选项。

&emsp;&emsp;话说我们需不需要弄一个LOL里面那种面板？我的建议是算了吧。

&emsp;&emsp;那么有哪些可以采用的进化选项呢？以下为口胡的暂定：

- 生命值+50
- 攻击力+10
- 攻击速度增加（靠，如果提供这个选项的话，我们需要一个攻速的计算公式）
- 子弹飞行速度增加
- 飞机移动速度增加
- 子弹体积增大

> 打断一下，我们需要做一个生命恢复机制吗？要不要搞一个脱战回血的设定？emmm，算了，要不把回复血量放到进化选项里。不然感觉数值不好设置，同时会让好好的整形计算引入浮点数。

- 回复生命值50点


&emsp;&emsp;抽时间商议一下以上采用哪些，从而进一步进行类的构思。