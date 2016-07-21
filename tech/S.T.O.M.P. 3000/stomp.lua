function init()
	self.crashing = false;
	self.hold = false; -- true if special key 2 is pressed down
	self.upTimer = 0;
	self.damageTimer = 0;
	self.active = false;
	self.canRemoveEffect = false;
	self.cooldownTimer = 0;
	self.consume = false;
	self.direction = "";
 end
 
 function uninit()
	status.removeEphemeralEffect("nofalldamage");
end


function input(args)
	if args.moves["special"] == 2 and not self.hold and not self.active and self.cooldownTimer <= 0 then
		if mcontroller.onGround() then
			self.direction = "up";
		elseif not mcontroller.onGround() then
			self.direction = "down";
		end 
		self.consume = true;
	end

	if args.moves["special"] == 0 and self.hold then
		self.hold = false;
	end

end

function update(args)
	if self.consume then
		if status.consumeResource("energy",status.resourceMax("energy")/3) then
			if self.direction == "up" then
				mcontroller.setYVelocity(80);
				self.upTimer = 5;
				self.active = true;
				self.hold = true;
			elseif self.direction == "down" then
				mcontroller.setYVelocity(-80);
				self.active = true;
				self.crashing = true;
				self.hold = true;
			end
		end
		self.consume = false;
	end

	-- cooldown timer 
	if self.cooldownTimer > 0 then
		self.cooldownTimer = self.cooldownTimer - 1;
	end

	-- If the tech can remove the tech form the player,
	-- I need a delay since it takes some time for the fall damage to be calculated
	-- and I thought 10 ticks was enough, I might lower it later.
	if self.canRemoveEffect and self.damageTimer <= 0 then
		status.removeEphemeralEffect("nofalldamage");
		self.hasToCoolDown = true;
		self.canRemoveEffect = false;

	end

	-- reduce time on the timer when it is done it will will alow the tech to remove the nofalldamage effect
	if self.damageTimer > 0 then
		self.damageTimer = self.damageTimer - 1;
	end

	-- if you're beeing shot in the air, self.active is true
	if self.active then
		-- reapplyed constantly as long as you are in the air
		status.addEphemeralEffect("nofalldamage");


		-- when the upTimer hits 0 or you start going down, this throws you down at 80 blocks/seconds
		if self.upTimer <= 0 or mcontroller.yVelocity()<0 then
			self.upTimer = 0;
			self.crashing = true;
			mcontroller.setYVelocity(-80);
			
		end

		-- when you hit the ground it throws 2 wave projectiles at the feet of the player,
		-- it also starts the timer used to remove the nofalldamage effect
		if self.crashing and mcontroller.onGround() then
			self.cooldownTimer = 110;
			world.spawnProjectile("regularexplosion2", {mcontroller.xPosition(),mcontroller.yPosition()-2}, entity.id(), {0,0}, false,{power = status.stat("powerMultiplier")*(5+(math.random()*5))});
			world.spawnProjectile("stompWave", {mcontroller.xPosition(),mcontroller.yPosition()-2}, entity.id(), {-1,0}, false,{power = status.stat("powerMultiplier")*(5+(math.random()*5))});
			world.spawnProjectile("stompWave", {mcontroller.xPosition(),mcontroller.yPosition()-2}, entity.id(), {1,0}, false,{power = status.stat("powerMultiplier")*(5+(math.random()*5))});
			self.crashing = false;
			self.active = false;
			self.damageTimer = 10;
			self.canRemoveEffect = true;
		end

		-- lowerst the upTimer, once it is done, you are beeing thrown at the ground at 80 blocks/seconds
		if self.upTimer > 0 and not self.crashing then
			self.upTimer = self.upTimer - 1;
		end
	end

	-- VISUAL HELP
	debugHelp();
end

-- simple debugging, use /debug to see
function debugHelp()
	world.debugText("cooldown timer: "..tostring(self.cooldownTimer),{mcontroller.xPosition()-3.5,mcontroller.yPosition()+3},"green")

	if self.active then
		world.debugText("active: "..tostring(self.active),{mcontroller.xPosition()+2.5,mcontroller.yPosition()-3},"green")
	elseif not self.active then
		world.debugText("active: "..tostring(self.active),{mcontroller.xPosition()+2.5,mcontroller.yPosition()-3},"red")
	end

	if self.crashing then
		world.debugText("crashing: "..tostring(self.crashing),{mcontroller.xPosition()-2.5,mcontroller.yPosition()-3},"green")
	elseif not self.crashing then
		world.debugText("crashing: "..tostring(self.crashing),{mcontroller.xPosition()-2.5,mcontroller.yPosition()-3},"red")
	end
end
