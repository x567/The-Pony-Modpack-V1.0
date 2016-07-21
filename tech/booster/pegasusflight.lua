function init()
  -- FLIGHT VARIABLES
  self.lastJump = false
  self.lastBoost = nil
  self.lastBoostDirection = nil
  -- RAINBOOM VARIABLES
  self.airDashing = false
  self.dashing = false
  self.dashTimer = 0
  self.dashDirection = 0
  self.dashLastInput = 0
  self.dashTapLast = 0
  self.dashTapTimer = 0
  -- CUSTOM VARIABLES
  	self.isFlying = false
	self.isRainboom = false
	-- DASH ACTION REPLACER
	self.rainboomAction = nil
	self.dashCooldownTimer = 0
  self.energyUsagePerSecond = config.getParameter("energyUsagePerSecond")
  self.boostSpeed = config.getParameter("boostSpeed")
  self.boostControlForce = config.getParameter("boostControlForce")
  self.maximumDoubleTapTime = config.getParameter("maximumDoubleTapTime")
   
  
  self.dashControlForce = config.getParameter("dashControlForce")
  self.dashSpeed = config.getParameter("dashSpeed")
  self.dashDuration = config.getParameter("dashDuration")
  self.groundOnly = config.getParameter("groundOnly")
  self.groundValid = not groundOnly or mcontroller.onGround()
  
  
end

function input(args)
	-- VISUAL DEBUGING HELP
	debughelp()
	
	-- FLIGHT VARIABLES
	local currentJump = args.moves["jump"]
	local currentBoost = nil


  if not mcontroller.onGround() then
  	if not mcontroller.canJump() and currentJump and not self.lastJump then
  		if args.moves["right"] and args.moves["up"] then
 			currentBoost = "boostRightUp"
  		elseif args.moves["right"] and args.moves["down"] then
  			currentBoost = {self.boostSpeed * diag, -self.boostSpeed * diag}
  		elseif args.moves["left"] and args.moves["up"] then
  			currentBoost = {-self.boostSpeed * diag, self.boostSpeed * diag}
  		elseif args.moves["left"] and args.moves["down"] then
  			currentBoost = {-self.boostSpeed * diag, -self.boostSpeed * diag}
  		elseif args.moves["right"] then
 			currentBoost = {self.boostSpeed, 0}
  		elseif args.moves["down"] then
  			currentBoost = {0, -self.boostSpeed}
 		elseif args.moves["left"] then
  			currentBoost = {-self.boostSpeed, 0}
 		elseif args.moves["up"] then
  			currentBoost = {0, self.boostSpeed}
  		end
  	elseif currentJump and self.lastBoost then
 		currentBoost = self.lastBoost
  	end
  end

  if self.isFlying and not mcontroller.onGround() then
 	if args.moves["right"] and args.moves["up"] then
  		currentBoost = {self.boostSpeed * diag, self.boostSpeed * diag}
  	elseif args.moves["right"] and args.moves["down"] then
  		currentBoost = {self.boostSpeed * diag, -self.boostSpeed * diag}
  	elseif args.moves["left"] and args.moves["up"] then
  		currentBoost = {-self.boostSpeed * diag, self.boostSpeed * diag}
  	elseif args.moves["left"] and args.moves["down"] then
  		currentBoost = {-self.boostSpeed * diag, -self.boostSpeed * diag}
  	elseif args.moves["right"] then
  		currentBoost = {self.boostSpeed, 0}
  	elseif args.moves["down"] then
  		currentBoost = {0, -self.boostSpeed}
  	elseif args.moves["left"] then
  		currentBoost = {-self.boostSpeed, 0}
  	elseif args.moves["up"] then
  		currentBoost = {0, self.boostSpeed}
 	end
  end
  self.lastJump = currentJump
  self.lastBoost = currentBoost
	
  debughelp()
	
 return currentBoost
end
function update(args)
  local boostDirection= false
  local diag = 1 / math.sqrt(2)
  	local currentJump = args.moves["jump"]
	local currentBoost = nil

	-- RAINBOOM TIMER
	if self.dashTimer > 0 then
		
	end
	self.rainboomAction = nil
  
  
  
  
  
  
  
  
  
  if not mcontroller.onGround() then
    if not mcontroller.canJump() and args.moves["jump"] and not self.lastJump then
      

      if args.moves["right"] and args.moves["up"] then
        boostDirection = {self.boostSpeed * diag, self.boostSpeed * diag}
      elseif args.moves["right"] and args.moves["down"] then
        boostDirection = {self.boostSpeed * diag, -self.boostSpeed * diag}
      elseif args.moves["left"] and args.moves["up"] then
        boostDirection = {-self.boostSpeed * diag, self.boostSpeed * diag}
      elseif args.moves["left"] and args.moves["down"] then
        boostDirection = {-self.boostSpeed * diag, -self.boostSpeed * diag}
      elseif args.moves["right"] then
        boostDirection = {self.boostSpeed, 0}
      elseif args.moves["down"] then
        boostDirection = {0, -self.boostSpeed}
      elseif args.moves["left"] then
        boostDirection = {-self.boostSpeed, 0}
      elseif args.moves["up"] then
        boostDirection = {0, self.boostSpeed}
      end
   

    end
  end



 if boostDirection and status.overConsumeResource("energy", self.energyUsagePerSecond * args.dt) then
  
  
    mcontroller.controlApproachVelocity(boostDirection, self.boostControlForce)

    
    animator.setParticleEmitterActive("boostParticles", true)
  else
    animator.setParticleEmitterActive("boostParticles", false)
  end
    if self.isFlying  then
		world.debugText("flying",{mcontroller.position()[1]-1,mcontroller.position()[2]-3.5}, "green")
	else
		world.debugText("not flying",{mcontroller.position()[1]-1.5,mcontroller.position()[2]-3.5}, "red")
	end
	
	if self.isRainboom  then
		world.debugText("rainboom",{mcontroller.position()[1]-1.8,mcontroller.position()[2]+1.5}, "green")
	else
		world.debugText("no rainboom",{mcontroller.position()[1]-2,mcontroller.position()[2]+1.5}, "red")
	end
end
