local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local gsub, strmatch = gsub, strmatch
local hooksecurefunc = hooksecurefunc

local function ReplaceTextColor(text, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

local function ReplaceGossipFormat(button, textFormat, text)
	local newFormat, count = gsub(textFormat, '000000', 'ffffff')
	if count > 0 then
		button:SetFormattedText(newFormat, text)
	end
end

local ReplacedGossipColor = {
	['000000'] = 'ffffff',
	['414141'] = '7b8489',
}

local function ReplaceGossipText(button, text)
	if text and text ~= '' then
		local newText, count = gsub(text, ':32:32:0:0', ':32:32:0:0:64:64:5:59:5:59')
		if count > 0 then
			text = newText
			button:SetFormattedText('%s', text)
		end

		local colorStr, rawText = strmatch(text, '|c[fF][fF](%x%x%x%x%x%x)(.-)|r')
		colorStr = ReplacedGossipColor[colorStr]
		if colorStr and rawText then
			button:SetFormattedText('|cff%s%s|r', colorStr, rawText)
		end
	end
end

local function ItemTextPage_SetTextColor(pageText, headerType, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		pageText:SetTextColor(headerType, 1, 1, 1)
	end
end

local function GreetingPanel_Update(frame)
	for _, button in next, { frame.ScrollTarget:GetChildren() } do
		if not button.IsSkinned then
			if button.GreetingText then
				button.GreetingText:SetTextColor(1, 1, 1)
				hooksecurefunc(button.GreetingText, 'SetTextColor', ReplaceTextColor)
			end

			local fontString = button.GetFontString and button:GetFontString()
			if fontString then
				fontString:SetTextColor(1, 1, 1)
				hooksecurefunc(fontString, 'SetTextColor', ReplaceTextColor)

				ReplaceGossipText(button, button:GetText())
				hooksecurefunc(button, 'SetText', ReplaceGossipText)
				hooksecurefunc(button, 'SetFormattedText', ReplaceGossipFormat)
			end

			button.IsSkinned = true
		end
	end
end

local function createParchment(frame)
	local tex = frame:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture([[Interface\QuestFrame\QuestBG]])
	tex:SetTexCoord(0, 0.586, 0.02, 0.655)
	return tex
end

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)
	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)
	S:HandleCloseButton(_G.ItemTextCloseButton)

	local GreetingPanel = _G.GossipFrame.GreetingPanel
	S:HandleTrimScrollBar(GreetingPanel.ScrollBar)
	S:HandleButton(GreetingPanel.GoodbyeButton, true)

	GreetingPanel:StripTextures()
	GreetingPanel:CreateBackdrop('Transparent')
	GreetingPanel.backdrop:Point('TOPLEFT', GreetingPanel.ScrollBox, 0, 0)
	GreetingPanel.backdrop:Point('BOTTOMRIGHT', GreetingPanel.ScrollBox, 0, 80)

	local ItemTextFrame = _G.ItemTextFrame
	ItemTextFrame:StripTextures()
	ItemTextFrame:CreateBackdrop('Transparent')
	ItemTextFrame.backdrop:ClearAllPoints()
	ItemTextFrame.backdrop:Point('TOPLEFT', ItemTextFrame, 5, -10)
	ItemTextFrame.backdrop:Point('BOTTOMRIGHT', ItemTextFrame, -25, 45)

	local ItemTextScrollFrame = _G.ItemTextScrollFrame
	ItemTextScrollFrame:DisableDrawLayer('ARTWORK')
	ItemTextScrollFrame:DisableDrawLayer('BACKGROUND')

	GossipFrame.backdrop:ClearAllPoints()
	GossipFrame.backdrop:Point('TOPLEFT', GreetingPanel.ScrollBox, -10, 70)
	GossipFrame.backdrop:Point('BOTTOMRIGHT', GreetingPanel.ScrollBox, 40, 40)

	S:HandleNextPrevButton(_G.ItemTextNextPageButton)
	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)

	if E.private.skins.parchmentRemoverEnable then
		_G.QuestFont:SetTextColor(1, 1, 1)
		_G.ItemTextPageText:SetTextColor('P', 1, 1, 1)

		hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', ItemTextPage_SetTextColor)
		hooksecurefunc(GreetingPanel.ScrollBox, 'Update', GreetingPanel_Update)

		if GossipFrame.Background then
			GossipFrame.Background:Hide()
		end
	else
		local spellTex = createParchment(GreetingPanel)
		spellTex:SetInside(GreetingPanel.backdrop)
		GreetingPanel.spellTex = spellTex

		local itemTex = createParchment(ItemTextFrame)
		itemTex:SetInside(ItemTextScrollFrame, -5)
		ItemTextFrame.itemTex = itemTex
	end
end

S:AddCallback('GossipFrame')
