package com.alex.component
{
	import com.alex.constant.OrderConst;
	import com.alex.constant.MoveDirection;
	import com.alex.constant.PhysicsType;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.display.Tree;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.role.MainRole;
	import com.alex.skill.SkillShow;
	import com.alex.util.Cube;
	import com.alex.util.IdMachine;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * 物理组件，代表显示对象在地图世界中的实体表示。长宽高，位置，
	 * @author alex
	 */
	public class PhysicsComponent implements IOrderExecutor, IRecycle
	{
		
		//public static const GRAVITY:Number = 9.8 * 1.7;
		public static const GRAVITY:Number = 9.8 * 1.2;
		
		///显示对象，拥有本移动组件的对象
		private var _displayObj:IDisplay;
		
		private var _length:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var _position:Position;
		
		private var _isMoveLeft:Boolean = false;
		private var _isMoveRight:Boolean = false;
		private var _isMoveUp:Boolean = false;
		private var _isMoveDown:Boolean = false;
		private var _isFlying:Boolean = false;
		private var _isDropping:Boolean = true;
		
		private var _xRunSpeed:Number;
		private var _yRunSpeed:Number;
		
		///物理类型
		private var _physicsType:int;
		
		///质量
		private var _mass:Number = 0;
		
		///x轴方向上的速度，负数为左，正数为右，0为停止
		private var _xVelocity:Number = 0;
		
		///y轴方向上的速度，负数为上，正数为下，0为停止
		private var _yVelocity:Number = 0;
		
		///z轴方向上的速度，负数为垂直向下，正数为垂直向上，0为停止
		private var _zVelocity:Number = 0;
		
		///摩擦系数
		private var _friction:Number = 0;
		
		///是否是自控状态
		private var _isSelfControl:Boolean = true;
		
		private var _isRelease:Boolean = false;
		
		private var _id:String;
		
		///托举着我的单位
		public var unitLiftMe:IPhysics;
		
		///踩着我的单位
		public var unitStandOnMeDic:Dictionary;
		
		///面向方向：1是向右，-1是向左
		private var _faceDirection:int = 1;
		
		public function PhysicsComponent()
		{
		
		}
		
		public function init(vDisplay:IDisplay, vPosition:Position, vSpeed:Number, vLength:Number, vWidth:Number, vHeight:Number, vMass:Number, vPhysicsType:int):PhysicsComponent
		{
			this._isRelease = false;
			this._id = IdMachine.getId(PhysicsComponent);
			
			this._displayObj = vDisplay;
			this._position = vPosition;
			
			this._length = vLength;
			this._width = vWidth;
			this._height = vHeight;
			
			this._xRunSpeed = vSpeed;
			this._yRunSpeed = vSpeed * 0.7;
			
			this._mass = vMass;
			
			this._friction = 0.3;
			
			this._isSelfControl = true;
			
			this._physicsType = vPhysicsType;
			
			this.unitStandOnMeDic = new Dictionary();
			
			Commander.registerExecutor(this);
			
			return this;
		}
		
		///开始移动
		///direction:0左，1右，2上，3下
		public function startMove(direction:int):void
		{
			if (!this._isSelfControl)
			{
				return;
			}
			switch (direction)
			{
				case MoveDirection.X_LEFT: 
					this._isMoveLeft = true;
					this._isMoveRight = false;
					this.faceDirection = -1;
					if (!this.isStandOnSomething() && _physicsType == PhysicsType.SOLID)
					{
						return;
					}
					if (this._isMoveUp)
					{
						this._yVelocity = -this._yRunSpeed * 0.7;
						this._xVelocity = -this._xRunSpeed * 0.7;
					}
					else if (this._isMoveDown)
					{
						this._yVelocity = this._yRunSpeed * 0.7;
						this._xVelocity = -this._xRunSpeed * 0.7;
					}
					else
					{
						this._xVelocity = -this._xRunSpeed;
					}
					break;
				case MoveDirection.X_RIGHT: 
					this._isMoveRight = true;
					this._isMoveLeft = false;
					this.faceDirection = 1;
					if (!this.isStandOnSomething() && _physicsType == PhysicsType.SOLID)
					{
						return;
					}
					if (this._isMoveUp)
					{
						this._yVelocity = -this._yRunSpeed * 0.7;
						this._xVelocity = this._xRunSpeed * 0.7;
					}
					else if (this._isMoveDown)
					{
						this._yVelocity = this._yRunSpeed * 0.7;
						this._xVelocity = this._xRunSpeed * 0.7;
					}
					else
					{
						this._xVelocity = this._xRunSpeed;
					}
					break;
				case MoveDirection.Y_UP: 
					this._isMoveUp = true;
					this._isMoveDown = false;
					if (!this.isStandOnSomething() && _physicsType == PhysicsType.SOLID)
					{
						return;
					}
					if (this._isMoveLeft)
					{
						this._xVelocity = -this._xRunSpeed * 0.7;
						this._yVelocity = -this._yRunSpeed * 0.7;
					}
					else if (this._isMoveRight)
					{
						this._xVelocity = this._xRunSpeed * 0.7;
						this._yVelocity = -this._yRunSpeed * 0.7;
					}
					else
					{
						this._yVelocity = -this._yRunSpeed;
					}
					break;
				case MoveDirection.Y_DOWN: 
					this._isMoveDown = true;
					this._isMoveUp = false;
					if (!this.isStandOnSomething() && _physicsType == PhysicsType.SOLID)
					{
						return;
					}
					if (this._isMoveLeft)
					{
						this._xVelocity = -this._xRunSpeed * 0.7;
						this._yVelocity = this._yRunSpeed * 0.7;
					}
					else if (this._isMoveRight)
					{
						this._xVelocity = this._xRunSpeed * 0.7;
						this._yVelocity = this._yRunSpeed * 0.7;
					}
					else
					{
						this._yVelocity = this._yRunSpeed;
					}
					break;
			}
		}
		
		///停止方向移动
		///direction:0左，1右，2上，3下
		public function stopMove(direction:int):void
		{
			if (!this._isSelfControl)
			{
				return;
			}
			switch (direction)
			{
				case MoveDirection.X_LEFT: 
					this._isMoveLeft = false;
					if (!this._isMoveRight && this.isStandOnSomething())
					{
						this._xVelocity = 0;
						if (_isMoveDown)
						{
							this._yVelocity = _yRunSpeed;
						}
						else if (_isMoveUp)
						{
							this._yVelocity = -_yRunSpeed;
						}
					}
					break;
				case MoveDirection.X_RIGHT: 
					this._isMoveRight = false;
					if (!this._isMoveLeft && this.isStandOnSomething())
					{
						this._xVelocity = 0;
						if (_isMoveDown)
						{
							this._yVelocity = _yRunSpeed;
						}
						else if (_isMoveUp)
						{
							this._yVelocity = -_yRunSpeed;
						}
					}
					break;
				case MoveDirection.Y_UP: 
					this._isMoveUp = false;
					if (!this._isMoveDown && this.isStandOnSomething())
					{
						this._yVelocity = 0;
						if (_isMoveLeft)
						{
							this._xVelocity = -_xRunSpeed;
						}
						else if (_isMoveRight)
						{
							this._xVelocity = _xRunSpeed;
						}
					}
					break;
				case MoveDirection.Y_DOWN: 
					this._isMoveDown = false;
					if (!this._isMoveUp && this.isStandOnSomething())
					{
						this._yVelocity = 0;
						if (_isMoveLeft)
						{
							this._xVelocity = -_xRunSpeed;
						}
						else if (_isMoveRight)
						{
							this._xVelocity = _xRunSpeed;
						}
					}
					break;
			}
		}
		
		///强制停止移动
		public function forceStopMove():void
		{
			this._isMoveLeft = false;
			this._isMoveRight = false;
			this._isMoveUp = false;
			this._isMoveDown = false;
			this._xVelocity = 0;
			this._yVelocity = 0;
		}
		
		public function forceStopZ():void
		{
			this._zVelocity = 0;
		}
		
		private var _isJump:Boolean = false;
		public var jumpEnery:int = 70;
		public function startJump():void {
			this._isJump = true;
		}
		
		public function endJump():void {
			this._isJump = false;
		}
		
		public function forceImpact(vDir:int, vVelocity:Number, isLoseControll:Boolean = false):void
		{
			if (isNaN(vVelocity))
			{
				return;
			}
			this._isSelfControl = this._isSelfControl && !isLoseControll;
			//if (this._displayObj is Skill && !this._isSelfControl) {
			//return;
			//}
			switch (vDir)
			{
				case MoveDirection.X_LEFT: 
					this._xVelocity -= vVelocity;
					break;
				case MoveDirection.X_RIGHT: 
					this._xVelocity += vVelocity;
					break;
				case MoveDirection.Y_UP: 
					this._yVelocity -= vVelocity;
					break;
				case MoveDirection.Y_DOWN: 
					this._yVelocity += vVelocity;
					break;
				case MoveDirection.Z_BOTTOM: 
					this._zVelocity -= vVelocity;
					break;
				case MoveDirection.Z_TOP: 
					this._zVelocity += vVelocity;
					break;
			}
		}
		
		public function get xEnergy():Number
		{
			if (this._xVelocity >= 0)
			{
				return 0.5 * this._mass * Math.pow(this._xVelocity, 2);
			}
			else
			{
				return -0.5 * this._mass * Math.pow(this._xVelocity, 2);
			}
		}
		
		public function get yEnergy():Number
		{
			if (this._yVelocity >= 0)
			{
				return 0.5 * this._mass * Math.pow(this._yVelocity, 2);
			}
			else
			{
				return -0.5 * this._mass * Math.pow(this._yVelocity, 2);
			}
		}
		
		public function get zEnergy():Number
		{
			if (this._zVelocity >= 0)
			{
				return 0.5 * this._mass * Math.pow(this._zVelocity, 2);
			}
			else
			{
				return -0.5 * this._mass * Math.pow(this._zVelocity, 2);
			}
		}
		
		///获取质量
		public function get mass():Number
		{
			return _mass;
		}
		
		///获取高度
		public function get height():Number
		{
			return _height;
		}
		
		///获取宽度
		public function get width():Number
		{
			return _width;
		}
		
		///获取长度
		public function get length():Number
		{
			return _length;
		}
		
		public function get physicsType():int
		{
			return _physicsType;
		}
		
		public function set physicsType(value:int):void
		{
			_physicsType = value;
		}
		
		///面向方向：1是向右，-1是向左
		public function get faceDirection():int
		{
			return _faceDirection;
		}
		
		public function set faceDirection(value:int):void
		{
			if (value != _faceDirection)
			{
				_faceDirection = value;
				this._displayObj.executeOrder(OrderConst.CHANGE_FACE_DIRECTION, this._faceDirection);
			}
		}
		
		///运行移动，需要每帧运行
		public function run(passedTime:Number, isFocus:Boolean = false):void
		{
			if (!(this._displayObj is MainRole))
			{
				//不在屏幕内的不更新
				var disObj:DisplayObject = this._displayObj.toDisplayObject();
				var pos:Point = disObj.parent.localToGlobal(new Point(disObj.x, disObj.y));
				if (pos.x < -disObj.width || pos.x > WorldMap.STAGE_WIDTH + disObj.width || pos.y < -disObj.height || pos.y > WorldMap.STAGE_HEIGHT + disObj.height)
				{
					return;
				}
			}
			var tempTime:Number = passedTime / 100;
			//=============垂直方向运动=============
			this._moveOnZ(passedTime, tempTime, isFocus);
			if (this._isRelease)
			{
				return;
			}
			this._displayObj.refreshElevation();
			//=======================================
			
			this._moveOnX(passedTime, tempTime, isFocus);
			if (this._isRelease)
			{ //执行完移动有可能已经释放
				return;
			}
			this._moveOnY(passedTime, tempTime, isFocus);
			if (this._isRelease)
			{ //执行完移动有可能已经释放
				return;
			}
			if (!this._isSelfControl && this._xVelocity == 0 && this._yVelocity == 0)
			{
				this._isSelfControl = true;
			}
		}
		
		private function _moveOnX(passedTime:Number, tempTime:Number, isFocus:Boolean):void
		{
			if (isBeCatched) return;
			if (!this._isSelfControl && (this._position.elevation == 0 || !this.unitLiftMe))
			{
				var a:Number = this._friction * GRAVITY;
			}
			else
			{
				a = 0;
			}
			if (this._xVelocity > 0)
			{
				var distance:int = this._xVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0)
				{
					this._xVelocity = Math.max(this._xVelocity - a * tempTime, 0);
				}
				if (distance > 0)
				{
					this._displayObj.executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.X_RIGHT, int(distance)]);
				}
			}
			else if (this._xVelocity < 0)
			{
				distance = -this._xVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0)
				{
					this._xVelocity = Math.min(this._xVelocity + a * tempTime, 0);
				}
				if (distance > 0)
				{
					this._displayObj.executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.X_LEFT, int(distance)]);
				}
			}
			else
			{
				//if (this._displayObj is Tree)
				//{
				//this._xVelocity = (Math.random() - 0.5) * 50;
				//this._isSelfControl = false;
				//}
			}
			if (this._isRelease)
			{
				return;
			}
			if (this.unitLiftMe && !this.unitLiftMe.physicsComponent.toCube().isLiftCube(this.toCube()))
			{
				this.unitLiftMe.physicsComponent.executeOrder(OrderConst.CANCEL_LIFT_UNIT, this._displayObj);
				this.unitLiftMe = null;
			}
			for (var unitId:String in this.unitStandOnMeDic)
			{
				var unit:IPhysics = this.unitStandOnMeDic[unitId] as IPhysics;
				if (unit && !this.toCube().isLiftCube(unit.physicsComponent.toCube()))
				{
					unit.physicsComponent.executeOrder(OrderConst.CANCEL_STAND_ON_UNIT);
					delete this.unitStandOnMeDic[unitId];
				}
			}
		}
		
		private function _moveOnY(passedTime:Number, tempTime:Number, isFocus:Boolean):void
		{
			if (isBeCatched) return;
			if (!this._isSelfControl && (this._position.elevation == 0 || !this.unitLiftMe))
			{
				var a:Number = this._friction * GRAVITY;
			}
			else
			{
				a = 0;
			}
			if (this._yVelocity > 0)
			{
				var distance:int = this._yVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0)
				{
					this._yVelocity = Math.max(this._yVelocity - a * tempTime, 0);
				}
				if (distance > 0)
				{
					this._displayObj.executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.Y_DOWN, int(distance)]);
				}
			}
			else if (this._yVelocity < 0)
			{
				distance = -this._yVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0)
				{
					this._yVelocity = Math.min(this._yVelocity + a * tempTime, 0);
				}
				if (distance > 0)
				{
					(this._displayObj as IOrderExecutor).executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.Y_UP, int(distance)]);
				}
			}
			else
			{
				//if (this._displayObj is Tree)
				//{
				//this._isSelfControl = false;
				//this._yVelocity = (Math.random() - 0.5) * 50;
				//}
			}
			if (this._isRelease)
			{
				return;
			}
			if (this.unitLiftMe && !this.unitLiftMe.physicsComponent.toCube().isLiftCube(this.toCube()))
			{
				this.unitLiftMe.physicsComponent.executeOrder(OrderConst.CANCEL_LIFT_UNIT, this._displayObj);
				this.unitLiftMe = null;
			}
			for (var unitId:String in this.unitStandOnMeDic)
			{
				var unit:IPhysics = this.unitStandOnMeDic[unitId] as IPhysics;
				if (unit && !this.toCube().isLiftCube(unit.physicsComponent.toCube()))
				{
					unit.physicsComponent.executeOrder(OrderConst.CANCEL_STAND_ON_UNIT);
					delete this.unitStandOnMeDic[unitId];
				}
			}
		}
		
		public var isBeCatched:Boolean = false;
		/**
		 * 垂直方向的移动处理
		 * @param	passedTime
		 * @param	tempTime
		 * @param	isFocus
		 */
		private function _moveOnZ(passedTime:Number, tempTime:Number, isFocus:Boolean):void
		{
			if (isBeCatched) return;
			if (!this.isStandOnSomething())
			{
				var a:Number = GRAVITY;
			}
			else
			{
				a = 0;
			}
			if (this._zVelocity != 0)
			{
				//垂直碰撞，以后加入动量守恒，这里先直接设动能为0
				//if (this.unitStandOnMeDic) 
				//{
				//this._zVelocity = 0;
				//} 
			}
			if (this._zVelocity > 0)
			{
				this._isFlying = true;
				this._isDropping = false;
				var distance:Number = this._zVelocity * tempTime - 0.5 * a * tempTime * tempTime;
				this._zVelocity -= GRAVITY * passedTime / 100;
				if (this._zVelocity <= 0)
				{
					this._isDropping = true;
					this._isFlying = false;
				}
				this._displayObj.executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.Z_TOP, int(distance)]);
				if (this.unitLiftMe && !this.unitLiftMe.physicsComponent.toCube().isLiftCube(this.toCube()))
				{
					this.unitLiftMe.physicsComponent.executeOrder(OrderConst.CANCEL_LIFT_UNIT, this._displayObj);
					this.unitLiftMe = null;
				}
				for (var unitId:String in this.unitStandOnMeDic)
				{
					var unit:IPhysics = this.unitStandOnMeDic[unitId] as IPhysics;
					if (unit && !this.toCube().isLiftCube(unit.physicsComponent.toCube()))
					{
						unit.physicsComponent.executeOrder(OrderConst.CANCEL_STAND_ON_UNIT);
						delete this.unitStandOnMeDic[unitId];
					}
				}
			}
			else if (!this.isStandOnSomething()) //在空中
			{
				if (_physicsType == PhysicsType.SOLID)
				{
					this._isDropping = true;
					distance = 0.5 * a * tempTime * tempTime - this._zVelocity * tempTime;
					this._zVelocity -= GRAVITY * passedTime / 100;
					this._displayObj.executeOrder(OrderConst.MAP_ITEM_MOVE, [MoveDirection.Z_BOTTOM, int(distance)]);
				}
			}
			if (this._isRelease)
			{
				return;
			}
			if (this.isStandOnSomething()) {
				if (this._isDropping) //站立在一个实体之上
				{
					//着地一刻
					this._zVelocity = 0;
					if (!this.unitLiftMe)
					{
						this._position.elevation = 0;
					}
					if (this._isSelfControl)
					{
						if ((_isMoveLeft || _isMoveRight) && (_isMoveUp || _isMoveDown))
						{
							if (_isMoveRight)
								_xVelocity = this._xRunSpeed * 0.7;
							else
								_xVelocity = -this._xRunSpeed * 0.7;
							if (_isMoveDown)
								_yVelocity = this._yRunSpeed * 0.7;
							else
								_yVelocity = -this._yRunSpeed * 0.7;
						}
						else if (_isMoveLeft || _isMoveRight)
						{
							if (_isMoveRight)
								_xVelocity = this._xRunSpeed;
							else
								_xVelocity = -this._xRunSpeed;
							_yVelocity = 0;
						}
						else if (_isMoveUp || _isMoveDown)
						{
							if (_isMoveDown)
								_yVelocity = this._yRunSpeed;
							else
								_yVelocity = -this._yRunSpeed;
							_xVelocity = 0;
						}
						else
						{
							_xVelocity = 0;
							_yVelocity = 0;
						}
					}
					this._isDropping = false;
					this._isFlying = false;
					
					//if (this._displayObj is Tree) 
					//this.forceImpact(ForceDirection.Z_TOP, 100);
				}
				else //站立在实体上
				{
					if (this._isJump) {
						this.forceImpact(MoveDirection.Z_TOP, jumpEnery);
					}
				}
			}
		}
		
		/* INTERFACE com.alex.pattern.ICommandHandler */
		
		public function getExecuteOrderList():Array
		{
			return [OrderConst.MAP_ITEM_FORCE_MOVE + this._displayObj.id, 
			OrderConst.STAND_ON_UNIT, OrderConst.LIFT_UNIT];
		}
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case OrderConst.MAP_ITEM_FORCE_MOVE + this._displayObj.id: 
					var dir:int = orderParam.dir as int;
					var energy:Number = orderParam.energy as Number;
					var loseControll:Boolean = orderParam.loseControll as Boolean;
					this.forceImpact(dir, energy, loseControll);
					break;
				case OrderConst.STAND_ON_UNIT: 
					this.unitLiftMe = orderParam as IPhysics;
					if (this.unitLiftMe)
					{
						this.unitLiftMe.physicsComponent.executeOrder(OrderConst.LIFT_UNIT, this._displayObj);
					}
					break;
				case OrderConst.LIFT_UNIT: 
					if (orderParam is IPhysics)
					{
						this.unitStandOnMeDic[(orderParam as IPhysics).id] = orderParam;
					}
					break;
				case OrderConst.CANCEL_LIFT_UNIT: 
					var unitId:String = (orderParam as IPhysics).id;
					if (this.unitStandOnMeDic[unitId])
					{
						delete this.unitStandOnMeDic[unitId];
					}
					break;
				case OrderConst.CANCEL_STAND_ON_UNIT: 
					this.unitLiftMe = null;
					break;
			}
		}
		
		public function getExecutorId():String
		{
			return this._id;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function release():void
		{
			Commander.cancelExecutor(this);
			InstancePool.recycle(this);
			if (this.unitLiftMe)
			{
				this.unitLiftMe.physicsComponent.executeOrder(OrderConst.CANCEL_LIFT_UNIT, this._displayObj);
				this.unitLiftMe = null;
			}
			for each (var unit:IPhysics in this.unitStandOnMeDic)
			{
				unit.physicsComponent.executeOrder(OrderConst.CANCEL_STAND_ON_UNIT, this._displayObj);
			}
			this._isRelease = true;
			this._displayObj = null;
			this._position = null;
			this._friction = 0;
			this._xVelocity = 0;
			this._yVelocity = 0;
			this._zVelocity = 0;
			this._id = null;
		
		}
		
		public function toCube():Cube
		{
			return new Cube(_position.globalX - (_length >> 1), _position.globalY - (_width >> 1), _position.elevation, _length, _width, _height);
		}
		
		///是否站立在某些东西之上
		public function isStandOnSomething():Boolean
		{
			return this._position.elevation <= 0 || this.unitLiftMe;
		}
		
		public static function make(display:IDisplay, position:Position, speed:int, length:int, width:int, height:int, mass:int, physicsType:int):PhysicsComponent
		{
			//InstancePool.getPhysicsComponent(display, position, speed, length, width, height, mass, physicsType);
			return PhysicsComponent(InstancePool.getInstance(PhysicsComponent)).init(display, position, speed, length, width, height, mass, physicsType);
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function isRelease():Boolean
		{
			return this._isRelease;
		}
	
	}

}