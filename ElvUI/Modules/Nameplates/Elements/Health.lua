local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local _G = _G
local pairs = pairs
local CreateFrame = CreateFrame

--overrides oUF's color function
function NP:UpdateColor(unit, cur, max)
	local parent = self.__owner

	local r, g, b, t

	if(self.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = parent.colors.tapped
	elseif self.ColorOverride then
		t = self.ColorOverride
	elseif(self.colorDisconnected and self.disconnected) then
		t = parent.colors.disconnected
	elseif(self.colorClass and UnitIsPlayer(unit)) or
		(self.colorClassNPC and not UnitIsPlayer(unit)) or
		(self.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = parent.colors.class[class]
	elseif(self.colorReaction and UnitReaction(unit, 'player')) then
		t = parent.colors.reaction[UnitReaction(unit, 'player')]
	elseif(self.colorSmooth) then
		r, g, b = parent:ColorGradient(cur, max, unpack(self.smoothGradient or parent.colors.smooth))
	elseif(self.colorHealth) then
		t = parent.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(r or g or b) then
		self:SetStatusBarColor(r, g, b)

		local bg = self.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate:GetDebugName()..'Health', nameplate)
	Health:SetFrameStrata(nameplate:GetFrameStrata())
	Health:SetFrameLevel(5)
	Health:CreateBackdrop('Transparent')
	Health:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
	Health.UpdateColor = NP.UpdateColor
	--[[Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints()
	Health.bg:SetTexture(E.media.blankTex)
	Health.bg.multiplier = 0.2]]
	NP.StatusBars[Health] = true

	local statusBarTexture = Health:GetStatusBarTexture()

	nameplate.FlashTexture = Health:CreateTexture(nameplate:GetDebugName()..'FlashTexture', "OVERLAY")
	nameplate.FlashTexture:SetTexture(E.Libs.LSM:Fetch("background", "ElvUI Blank"))
	nameplate.FlashTexture:Point("BOTTOMLEFT", statusBarTexture, "BOTTOMLEFT")
	nameplate.FlashTexture:Point("TOPRIGHT", statusBarTexture, "TOPRIGHT")
	nameplate.FlashTexture:Hide()

	Health.Smooth = true
	Health.colorReaction = true
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = false
		
	return Health
end

function NP:Update_Health(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate.Health.colorClass = db.health.useClassColor

	if db.health.enable then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:SetPoint('CENTER', nameplate, 'CENTER', 0, db.health.yOffset)
	else
		if nameplate:IsElementEnabled('Health') then
			nameplate:DisableElement('Health')
		end
	end

	if db.health.text.enable then
		nameplate.Health.Text:ClearAllPoints()
		nameplate.Health.Text:SetPoint(E.InversePoints[db.health.text.position], nameplate, db.health.text.position, db.health.text.xOffset, db.health.text.yOffset)
		nameplate.Health.Text:Show()
	else
		nameplate.Health.Text:Hide()
	end

	nameplate:Tag(nameplate.Health.Text, db.health.text.format)

	nameplate.Health.width = db.health.width
	nameplate.Health.height = db.health.height
	nameplate.Health:SetSize(db.health.width, db.health.height)
end

function NP:Construct_HealthPrediction(nameplate)
	local HealthPrediction = CreateFrame('Frame', nameplate:GetDebugName()..'HealthPrediction', nameplate)

	for _, Bar in pairs({ 'myBar', 'otherBar', 'absorbBar', 'healAbsorbBar' }) do
		HealthPrediction[Bar] = CreateFrame('StatusBar', nil, nameplate.Health)
		HealthPrediction[Bar]:SetFrameStrata(nameplate:GetFrameStrata())
		HealthPrediction[Bar]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		HealthPrediction[Bar]:SetPoint('TOP')
		HealthPrediction[Bar]:SetPoint('BOTTOM')
		HealthPrediction[Bar]:SetWidth(150)
		NP.StatusBars[HealthPrediction[Bar]] = true
	end

	HealthPrediction.myBar:SetPoint('LEFT', nameplate.Health:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.myBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 2)
	HealthPrediction.myBar:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
	HealthPrediction.myBar:SetMinMaxValues(0, 1)

	HealthPrediction.otherBar:SetPoint('LEFT', HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.otherBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 1)
	HealthPrediction.otherBar:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)

	HealthPrediction.absorbBar:SetPoint('LEFT', HealthPrediction.otherBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.absorbBar:SetFrameLevel(nameplate.Health:GetFrameLevel())
	HealthPrediction.absorbBar:SetStatusBarColor(NP.db.colors.healPrediction.absorbs.r, NP.db.colors.healPrediction.absorbs.g, NP.db.colors.healPrediction.absorbs.b)

	HealthPrediction.healAbsorbBar:SetPoint('RIGHT', nameplate.Health:GetStatusBarTexture())
	HealthPrediction.healAbsorbBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 3)
	HealthPrediction.healAbsorbBar:SetStatusBarColor(NP.db.colors.healPrediction.healAbsorbs.r, NP.db.colors.healPrediction.healAbsorbs.g, NP.db.colors.healPrediction.healAbsorbs.b)
	HealthPrediction.healAbsorbBar:SetReverseFill(true)

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	return HealthPrediction
end

function NP:Update_HealthPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.health.enable and db.health.healPrediction then
		if not nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:EnableElement('HealthPrediction')
		end
	else
		if nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:DisableElement('HealthPrediction')
		end
	end

	nameplate.HealthPrediction.myBar:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
	nameplate.HealthPrediction.otherBar:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)
	nameplate.HealthPrediction.absorbBar:SetStatusBarColor(NP.db.colors.healPrediction.absorbs.r, NP.db.colors.healPrediction.absorbs.g, NP.db.colors.healPrediction.absorbs.b)
	nameplate.HealthPrediction.healAbsorbBar:SetStatusBarColor(NP.db.colors.healPrediction.healAbsorbs.r, NP.db.colors.healPrediction.healAbsorbs.g, NP.db.colors.healPrediction.healAbsorbs.b)
end
