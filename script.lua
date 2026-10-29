local PirOdd = require("PirateOddities")
local physBone = require('physBoneAPI_MODIFIED')

-- deepcopy, aquired from figura discord #code-snippets by manuel_2867
function deepcopy(part, name)
    local copy = part:copy(part:getName() .. (name or "_copy"))
    for _, child in ipairs(part:getChildren()) do
        copy:removeChild(child)
        deepcopy(child):moveTo(copy)
    end
    return copy
end

MODELPATH = models.demongirl
ANIMPATH = animations.demongirl

local poseState = false
local stanceState = false

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)

models.demongirl.root.UpperBody.Body.Tail.Tail2.Tail3.Tail4.tip:setPrimaryRenderType("CUTOUT_CULL")

deepcopy(MODELPATH.root.UpperBody.Head):setParentType("PORTRAIT"):moveTo(MODELPATH):setPos(0,-26,0)
deepcopy(MODELPATH.root.UpperBody.Head):setParentType("SKULL"):moveTo(MODELPATH):setPos(0,-26,0)

local bodySmoothRot = PirOdd.SmoothRot(MODELPATH.root.UpperBody)
bodySmoothRot.crouchBody = vec(0,1,0)
bodySmoothRot.crouchHead = vec(0,-3,0)

local ears = PirOdd.Ears(MODELPATH.root.UpperBody.Head.LeftEar, MODELPATH.root.UpperBody.Head.RightEar)
ears.flickChance = -1
ears.velIntensity = 10

ears.minYaw = -10
ears.maxYaw = 10
		
ears.minPitch = -15
ears.maxPitch = 15

local eyes = PirOdd.Eyes(MODELPATH.root.UpperBody.Head.Eyes.LEye, MODELPATH.root.UpperBody.Head.Eyes.REye, ANIMPATH.blink, ANIMPATH.closeeyes)

local breasts = PirOdd.BouncyPart(MODELPATH.root.UpperBody.Body.UpperTorso.Breasts, vec(0,0.15,0), vec(2.1,2.5,1))

breasts.rotBounce.min = vec(-30,-20,-10)
breasts.rotBounce.max = vec(30,15,10)

breasts.posBounce.min = vec(0,-0.5,0)
breasts.posBounce.max = vec(0,0.5,0)

breasts.breastStuff = true

local tail = PirOdd.tail(MODELPATH.root.UpperBody.Body.Tail)

tail.idleXIntensity = 30
tail.idleYIntensity = 10

tail.segmentDecay = 0.8
tail.segmentOffset = 7

-- actions
local page = action_wheel:newPage()
action_wheel:setPage(page)

-- pose
function pose(state)
	poseState = state
	ANIMPATH.pose:setPlaying(state)
end

function stance(state)
	stanceState = state
	ANIMPATH.weaponstance:setPlaying(state)
end

function pings.pose(state)
	pose(state)
	
	if stanceState then
		stance(false)
		ActionStance:setToggled(false)
	end
end

ActionPose = page:newAction()
	:setTitle("Pose")
	:setTexture(textures["icons.pose"])
	:setOnToggle(pings.pose)
	
function pings.stance(state)
	stance(state)

	if poseState then
		pose(false)
		ActionPose:setToggled(false)
	end
end

ActionStance = page:newAction()
	:setTitle("Stance")
	:setTexture(textures["icons.sword"])
	:setOnToggle(pings.stance)

function events.entity_init()
	-- buncha physbone stuff
	physBone:setPreset("bangs",0.2,6,nil,0.4,nil,vec(0,-1,0),10)
	
	local leftBangRot = MODELPATH.root.UpperBody.Head.Hair.LeftBang:getRot()
	local rightBangRot = MODELPATH.root.UpperBody.Head.Hair.RightBang:getRot()
	
	leftBang = MODELPATH.root.UpperBody.Head.Hair.LeftBang:newPhysBone("bangs"):setNodeEnd(3):setRotMod(leftBangRot):setBounce(0):setAngleLimits({-30,30,-5,20}):setSimSpeed(0.5)
	rightBang = MODELPATH.root.UpperBody.Head.Hair.RightBang:newPhysBone("bangs"):setNodeEnd(3):setRotMod(rightBangRot):setBounce(0):setAngleLimits({-30,30,-5,20}):setSimSpeed(0.5)
	
	ponyTailRot = MODELPATH.root.UpperBody.Head.Hair.Ponytail:getRot()
	
	ponyTail = MODELPATH.root.UpperBody.Head.Hair.Ponytail:newPhysBone("bangs"):setNodeEnd(3):setRotMod(ponyTailRot):setBounce(0):setAngleLimits({-60,60,-90,5}):setSimSpeed(0.5)
	
	ponyTail2Rot = MODELPATH.root.UpperBody.Head.Hair.Ponytail.Ponytail2.Ponytail3:getRot()
	
	ponyTail2 = MODELPATH.root.UpperBody.Head.Hair.Ponytail.Ponytail2.Ponytail3:newPhysBone("bangs"):setNodeEnd(3):setRotMod(ponyTail2Rot):setSimSpeed(0.5)
end

function events.tick()
	if player:getVelocity():length() > 0.05 or player:isCrouching() then
		if poseState then
			pose(false)
			ActionPose:setToggled(false)
		end
		if stanceState then
			stance(false)
			ActionStance:setToggled(false)
		end
	end
end

function events.render(delta)
	if player:isLoaded() then
		--MODELPATH.root.UpperBody.Head.Hair.Ponytail:setRot(vec(math.max(bodySmoothRot.instantHeadRot.x,-25),bodySmoothRot.instantHeadRot.y,bodySmoothRot.instantHeadRot.z)*vec(-1,-0.5,-0.5) + (player:isCrouching() and vec(-30,0,0) or vec(0,0,0)))
	end
end

function events.item_render(item, context)
	if item.id:find("sword") or item.id:find("trident") then
		if context:find("FIRST_PERSON") then
			MODELPATH.ItemTrident:setScale(0.75)
		else
			MODELPATH.ItemTrident:setScale(1)
		end
		return MODELPATH.ItemTrident
	end
end