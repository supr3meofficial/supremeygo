--Number L1: Cybertron Gate Cyx
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	--double ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	--battle indestructable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(s.indes)
	c:RegisterEffect(e4)
end
function s.sprfilter(c)
	return c:GetLevel()==1 and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
function s.sprcon(e,c,tp)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if g then return true end
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	local mg1=aux.SelectUnselectGroup(g,e,tp,3,3,nil,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #mg1==3 then
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
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()~=tp
		and e:GetHandler():IsPreviousControler(tp)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9999)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end