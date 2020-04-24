--Number iL1000: Cyberonius Cyberonia
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
	--special summon from destruction of Cyberonius
	local sp2=Effect.CreateEffect(c)
	sp2:SetDescription(aux.Stringid(id,0))
	sp2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	sp2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	sp2:SetRange(LOCATION_EXTRA)
	sp2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	sp2:SetCode(EVENT_LEAVE_FIELD)
	sp2:SetCondition(s.spcon)
	sp2:SetTarget(s.sptg)
	sp2:SetOperation(s.spop)
	c:RegisterEffect(sp2)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes) --except with "Number" monsters
	c:RegisterEffect(e1)
	--cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ONLY_BE_ATTACKED)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e5)
	--win
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetOperation(s.winop)
	c:RegisterEffect(e6)
	--gain LP
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_RECOVER)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_FLAG_DELAY+EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
end
s.listed_series={0x48}
s.listed_names={99900009}
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
--sp2
function s.cfilter(c,e,tp)
	return c:IsCode(99900009) and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and (not e or c:IsRelateToEffect(e))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,nil,tp,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,nil,tp,e:GetHandler())
	if chk==0 then
		return Duel.GetLocationCountFromEx(tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,true,false) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
-- e1
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
--e6
function s.check(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp or Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.chkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp and Duel.GetFlagEffect(tp,id)==0 then
		Duel.Win(tp,0xff)
	end
end
--e7
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and aux.nzatk(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if aux.nzatk(tc) and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(alias,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.reccon)
		e1:SetTarget(s.rectg)
		e1:SetOperation(s.recop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(alias)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabelObject():GetAttack())
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,e:GetLabelObject():GetAttack(),REASON_EFFECT)
end
