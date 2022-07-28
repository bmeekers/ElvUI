local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

local MAX_TALENT_TABS = MAX_TALENT_TABS

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	S:HandleFrame(_G.PlayerTalentFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.PlayerTalentFrameCloseButton, _G.PlayerTalentFrame.backdrop)

	for i = 1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	_G.PlayerTalentFrameRoleButton:Kill()

	for i = 1, MAX_TALENT_TABS do
		local tab = _G['PlayerSpecTab'..i]
		tab:GetRegions():Hide()

		tab:SetTemplate()
		tab:StyleButton(nil, true)

		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	end

	if _G.PlayerTalentFrameActivateButton then
		S:HandleButton(_G.PlayerTalentFrameActivateButton)
	end

	if _G.PlayerTalentFrameStatusFrame then
		_G.PlayerTalentFrameStatusFrame:StripTextures()
	end

	_G.PlayerTalentFrameScrollFrame:StripTextures()
	_G.PlayerTalentFrameScrollFrame:CreateBackdrop()

	S:HandleScrollBar(_G.PlayerTalentFrameScrollFrameScrollBar)
	_G.PlayerTalentFrameScrollFrameScrollBar:Point('TOPLEFT', _G.PlayerTalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	_G.PlayerTalentFrameSpentPointsText:Point('LEFT', _G.PlayerTalentFramePointsBar, 'LEFT', 12, -1)
	_G.PlayerTalentFrameTalentPointsText:Point('RIGHT', _G.PlayerTalentFramePointsBar, 'RIGHT', -12, -1)

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['PlayerTalentFrameTalent'..i]
		local icon = _G['PlayerTalentFrameTalent'..i..'IconTexture']
		local rank = _G['PlayerTalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
		end
	end

	_G.PlayerTalentFramePointsBar:StripTextures()
end
S:AddCallbackForAddon('Blizzard_TalentUI')

function S:Blizzard_GlyphUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	_G.GlyphFrame:StripTextures()

	_G.GlyphFrameBackground:Size(334, 385)
	_G.GlyphFrameBackground:Point('TOPLEFT', 15, -47)

	_G.GlyphFrameBackground:SetTexture('Interface\\Spellbook\\UI-GlyphFrame')
	_G.GlyphFrameGlow:SetTexture('Interface\\Spellbook\\UI-GlyphFrame-Glow')
	_G.GlyphFrameGlow:SetAllPoints(_G.GlyphFrameBackground)

	_G.GlyphFrameBackground:SetTexCoord(0.041015625, 0.65625, 0.140625, 0.8046875)
	_G.GlyphFrameGlow:SetTexCoord(0.05859375, 0.673828125, 0.06640625, 0.73046875)

	-- Otherwise TalenFrame texts/elements will overlap with Glyph texts/elements
	_G.GlyphFrame:HookScript('OnShow', function()
		_G.PlayerTalentFrameTitleText:Hide()
		_G.PlayerTalentFramePointsBar:Hide()
		_G.PlayerTalentFrameScrollFrame:Hide()
		_G.PlayerTalentFrameStatusFrame:Hide()
	end)

	_G.GlyphFrame:HookScript('OnHide', function()
		_G.PlayerTalentFrameTitleText:Show()
		_G.PlayerTalentFramePointsBar:Show()
		_G.PlayerTalentFrameScrollFrame:Show()
	end)
end
S:AddCallbackForAddon('Blizzard_GlyphUI')