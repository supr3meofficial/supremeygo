--Cyberon Calling
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={99900005}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(99900005)
end
function s.filter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsSetCard(0x9999) and c:IsType(TYPE_LINK)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local link=Effect.CreateEffect(e:GetHandler())
	link:SetType(EFFECT_TYPE_FIELD)
	link:SetCode(EFFECT_BECOME_LINKED_ZONE)
	link:SetValue(0xffffff)
	Duel.RegisterEffect(link,tp)
	if chk==0 then 
		link:Reset()
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,4,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	link:Reset()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local link=Effect.CreateEffect(e:GetHandler())
	link:SetType(EFFECT_TYPE_FIELD)
	link:SetCode(EFFECT_BECOME_LINKED_ZONE)
	link:SetValue(0xffffff)
	Duel.RegisterEffect(link,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g<=3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,4,4,nil)
	if #sg>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=sg:GetFirst()
		for tc in aux.Next(sg) do
			Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		end
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		Duel.RegisterEffect(e1,tp)
	end
	link:Reset()
end
function s.rmfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel())
	local tgc=tg:GetFirst()
	local atk=0
	for tc in aux.Next(tg) do
		local tatk=tc:GetAttack()
		if tatk>0 then atk=atk+tatk end
	end
	g:DeleteGroup()
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT) then
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end