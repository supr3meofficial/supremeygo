--Number L1000: Cyberonius
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon condition
	local sp=Effect.CreateEffect(c)
	sp:SetType(EFFECT_TYPE_SINGLE)
	sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	sp:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(sp)
	--special summon procedure
	local sp1=Effect.CreateEffect(c)
	sp1:SetType(EFFECT_TYPE_FIELD)
	sp1:SetCode(EFFECT_SPSUMMON_PROC)
	sp1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	sp1:SetRange(LOCATION_EXTRA)
	sp1:SetCondition(s.sprcon)
	sp1:SetTarget(s.sprtg)
	sp1:SetOperation(s.sprop)
	c:RegisterEffect(sp1)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes) --except with "Number" monsters
	c:RegisterEffect(e1)
	--negate and cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.negfilter) --non-Links
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.negfilter) --non-Links
	c:RegisterEffect(e3)
	--end of bp: banish opp monsters
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetTarget(s.bptg)
	e4:SetOperation(s.bpop)
	c:RegisterEffect(e4)
	--Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.desreptg)
	e5:SetOperation(s.desrepop)
	c:RegisterEffect(e5)
	--spsummon from opp extra deck
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.extratg)
	e6:SetOperation(s.extraop)
	c:RegisterEffect(e6)
end
s.listed_series={0x48}
-- sp1
function s.sprfilter(c)
	return c:GetLevel()==12 and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
function s.sprcon(e,c,tp)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	if g then return true end
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local mg1=aux.SelectUnselectGroup(g,e,tp,5,5,nil,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #mg1==5 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- e1
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
-- e2 and e3
function s.negfilter(e,c)
	return not c:IsType(TYPE_LINK)
end
-- e4
function s.bptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil) 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
end
-- e5
function s.repfilter(c)
	return not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,0,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,0,1,1,c)
		e:SetLabelObject(g:GetFirst())
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
--e6
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and Duel.IsPlayerCanSpecialSummon(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.extrafilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.extraop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local extrag=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_EXTRA,nil,e,tp)
	if #extrag>0 then
		Duel.ConfirmCards(1-tp, extrag)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local extra=extrag:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummon(extra,0,tp,tp,true,false,POS_FACEUP)
		Duel.ShuffleExtra(1-tp)
	end
end