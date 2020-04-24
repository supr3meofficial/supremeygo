--Cyberon Ritual
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={99900001,99900002,99900003,99900004,99900009}
function s.condition(e,tp,eg,ep,ev,re,r,rp) -- Check for banished gates
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,nil,99900001)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,nil,99900002)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,nil,99900003)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,nil,99900004)
end
function s.filter(c,e,tp)
	return c:IsCode(99900009) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local link=Effect.CreateEffect(e:GetHandler())
	link:SetType(EFFECT_TYPE_FIELD)
	link:SetCode(EFFECT_BECOME_LINKED_ZONE)
	link:SetValue(0xffffff)
	Duel.RegisterEffect(link,tp)
	if chk==0 then
	   link:Reset()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	link:Reset()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local link=Effect.CreateEffect(e:GetHandler())
	link:SetType(EFFECT_TYPE_FIELD)
	link:SetCode(EFFECT_BECOME_LINKED_ZONE)
	link:SetValue(0xffffff)
	Duel.RegisterEffect(link,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #tg>0 then
		local tc=tg:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	link:Reset()
end
