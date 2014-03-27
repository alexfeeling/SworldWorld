package com.alex.skill
{
	import com.alex.constant.MoveDirection;
	import com.alex.constant.OrderConst;
	import com.alex.pattern.Commander;
	import com.alex.unit.AttackableUnit;
	import com.alex.util.Cube;
	import com.alex.component.PhysicsComponent;
	import com.alex.display.IPhysics;
	import com.alex.worldmap.Position;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author alex
	 */
	public class SkillData
	{
		
		public var name:String;
		///是否单人伤害
		public var isSingleHurt:Boolean = true;
		///伤害范围，以格子行列数表示
		public var rangeOfHurt:Point;
		
		///最大作用目标个数
		public var maxImpactNum:int = 1;
		
		private var _currentFrame:int = 0;
		private var _maxFrame:int = 10;
		private var _frameData:Array;
		private var _attackableUnit:AttackableUnit;
		
		/**
		 * 技能类型：0锐器，1钝器，2拳脚，3内功
		 */
		public var type:int = 0;
		
		private var _fps:int = 60;
		private var _fTime:Number = 0;
		private var _tempTime:Number = 0;
		
		public function SkillData(attackableUnit:AttackableUnit, frameData:Array = null)
		{
			_fps = 16;
			_fTime = 1000 / _fps;
			_attackableUnit = attackableUnit;
			if (frameData)
			{
				_frameData = frameData;
			} else {
				_frameData = [{type:"end"}];
			}
		}
		
		public function run(passedTime:Number):void {
			_tempTime += passedTime;
			if (_tempTime >= _fTime)
			{
				_tempTime -= _fTime;
				var frameObj:Object = _frameData[_currentFrame];
				if (frameObj)
				{
					//if (frameObj.isEndCatch == true) {
						//_attackableUnit.releaseCatch();
					//}
					//trace(frameObj.type);
					switch(frameObj.type)
					{
						case "hurt":
							_attackableUnit.attackHurt(frameObj, getAttackCube());
							break;
						case "distance":
							if (frameObj.distanceId)
							{
								var sPosition:Position = this._attackableUnit.position.copy();
								var skill:Skill = Skill.make(frameObj.distanceId, this._attackableUnit, sPosition, this._attackableUnit.physicsComponent.faceDirection == 1 ? MoveDirection.X_RIGHT : MoveDirection.X_LEFT, 40, 10, frameObj);
								Commander.sendOrder(OrderConst.ADD_ITEM_TO_WORLD_MAP, skill);
							}
							break;
						case "catch":
							_attackableUnit.catchAndFollow(frameObj, getAttackCube());
							break;
						case "releaseCatch":
							_attackableUnit.releaseCatch();
							break;
						case "end":
							_attackableUnit.attackEnd();
							return;
					}
				}
				_currentFrame++;
				//if (_currentFrame >= _maxFrame)
					//_attackableUnit.attackEnd();
			}
		}
		
		public function getAttackCube():Cube
		{
			var ackPos:Position = _attackableUnit.position;
			var phyc:PhysicsComponent = _attackableUnit.physicsComponent;
			if (phyc.faceDirection == 1) {
				return new Cube(ackPos.globalX + 40, ackPos.globalY - 30, 
				ackPos.elevation, 80, 60, 80);
			} else {
				return new Cube(ackPos.globalX -80- 40, ackPos.globalY - 30, 
				ackPos.elevation, 80, 60, 80);
			}
		}
	
	}

}