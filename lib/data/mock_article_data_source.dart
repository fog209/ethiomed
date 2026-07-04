import '../models/article.dart';

abstract class ArticleRemoteDataSource {
  Future<List<Article>> fetchArticles();
}

class MockArticleDataSource implements ArticleRemoteDataSource {
  const MockArticleDataSource();

  @override
  Future<List<Article>> fetchArticles() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return mockArticles;
  }
}

const List<Article> mockArticles = <Article>[
  Article(
    title: 'Diabetes',
    category: ['Internal Medicine'],
    theEssence:
        '[[Diabetes]] is chronic hyperglycemia from impaired insulin secretion, insulin action, or both. In exams and wards, think of it as a vascular disease with glucose as the visible clue.',
    theLogic:
        'Persistent hyperglycemia causes osmotic diuresis, dehydration, infection risk, and long-term endothelial injury. Type 1 is absolute insulin deficiency; type 2 is insulin resistance with progressive beta-cell exhaustion.',
    thePortrait:
        'A patient may report polyuria, polydipsia, weight loss, blurred vision, recurrent skin infections, or numb feet. Some Ethiopian patients first present with [[Diabetic Ketoacidosis]] or a non-healing foot wound.',
    clinicalLink:
        'Link symptoms to complications: nocturia suggests osmotic diuresis, tingling suggests neuropathy, and proteinuria suggests nephropathy. Always connect [[Hypertension]] with diabetes because the combination accelerates kidney and vascular disease.',
    theEthiopianBedside:
        'Ask about medication access, fasting practices, food insecurity, foot-care habits, and distance from follow-up. Glucometer strips may be scarce, so symptom-based safety counseling matters.',
    survivalPearl:
        'Never treat the glucose number alone. Look for dehydration, ketones, infection, blood pressure, kidney function, and foot danger signs.',
    curiosityCorner:
        'Classic symptoms appear when glucose crosses the renal threshold, causing glucose to pull water into urine.',
    thePlan:
        'Confirm with fasting glucose, random glucose with symptoms, HbA1c when available, or oral glucose tolerance testing. Start lifestyle counseling, metformin for most type 2 patients if not contraindicated, insulin when catabolic or type 1, and screen eyes, kidneys, feet, and blood pressure.',
    relatedTopics: <String>[
      'Diabetic Ketoacidosis',
      'Hypertension',
      'Tuberculosis',
    ],
    mnemonics:
        'The 3 Ps are Polyuria, Polydipsia, and Polyphagia; add weight loss as the danger clue for insulin deficiency.',
  ),
  Article(
    title: 'Diabetic Ketoacidosis',
    category: ['Emergency Medicine', 'Endocrine Emergencies'],
    theEssence:
        '[[Diabetic Ketoacidosis]] is insulin deficiency causing hyperglycemia, ketosis, acidosis, and dehydration. It is a fluids-first emergency.',
    theLogic:
        'Without insulin, cells cannot use glucose well, counter-regulatory hormones rise, fat breaks down into ketones, and acidosis follows. Vomiting worsens potassium and volume loss.',
    thePortrait:
        'The patient is often young or has known [[Diabetes]], with vomiting, abdominal pain, deep breathing, dehydration, confusion, and sometimes an infection trigger such as [[Pneumonia]].',
    clinicalLink:
        'Kussmaul breathing is compensation for metabolic acidosis. Potassium may look normal or high before treatment, but total body potassium is depleted.',
    theEthiopianBedside:
        'Insulin interruption from cost, travel, or stock-outs is a common trigger to ask about. Infection screening should include chest, urine, skin, and pregnancy where relevant.',
    survivalPearl:
        'Give fluids before insulin unless a senior plan says otherwise. Insulin drives potassium into cells and can unmask dangerous hypokalemia.',
    curiosityCorner:
        'Abdominal pain in DKA can mimic a surgical abdomen, but it often improves as acidosis corrects.',
    thePlan:
        'Assess airway, breathing, circulation, glucose, ketones, electrolytes, renal function, and infection. Start isotonic fluids, potassium-guided insulin, frequent monitoring, and treat the trigger.',
    relatedTopics: <String>['Diabetes', 'Pneumonia', 'Sepsis'],
    mnemonics: 'DKA priorities: FLIP - Fluids, Labs, Insulin, Potassium.',
  ),
  Article(
    title: 'Hypertension',
    category: ['Internal Medicine', 'Cardiology'],
    theEssence:
        '[[Hypertension]] is persistently elevated arterial pressure that silently damages brain, heart, kidneys, eyes, and vessels.',
    theLogic:
        'High pressure increases afterload and injures endothelium. The body may tolerate it for years until target-organ damage appears as stroke, heart failure, kidney disease, or retinopathy.',
    thePortrait:
        'Most patients feel well. Clues are headache, visual symptoms, chest pain, dyspnea, neurologic deficit, or incidental high readings during visits for [[Diabetes]] or pregnancy care.',
    clinicalLink:
        'Separate urgency from emergency by target-organ damage, not by the number alone. Chest pain, pulmonary edema, confusion, focal weakness, and papilledema change the plan immediately.',
    theEthiopianBedside:
        'Check adherence barriers, salt use, khat use, NSAID use, and affordability of long-term medication. Confirm technique with correct cuff size when possible.',
    survivalPearl:
        'Do not rapidly drop chronic severe blood pressure unless there is a hypertensive emergency; organs may be adapted to higher pressure.',
    curiosityCorner:
        'The left ventricle thickens against pressure like a muscle training against resistance, but that adaptation eventually becomes harmful.',
    thePlan:
        'Repeat accurate measurements, assess cardiovascular risk, screen urine and creatinine, counsel salt reduction and activity, start appropriate medicines, and follow up for control and side effects.',
    relatedTopics: <String>['Diabetes', 'Preeclampsia', 'Stroke'],
    mnemonics: 'Target organs: BHKER - Brain, Heart, Kidneys, Eyes, Retinas.',
  ),
  Article(
    title: 'Pneumonia',
    category: ['Internal Medicine', 'Pulmonology'],
    theEssence:
        '[[Pneumonia]] is infection of lung parenchyma causing inflammation, impaired gas exchange, and systemic illness.',
    theLogic:
        'Alveoli fill with inflammatory fluid instead of air, so oxygen transfer falls. Severity depends on organism, host defense, aspiration risk, and baseline lung or immune status.',
    thePortrait:
        'Fever, cough, pleuritic chest pain, tachypnea, crackles, bronchial breath sounds, or hypoxia. In elders, confusion may be the first sign. Consider [[Tuberculosis]] if chronic cough, night sweats, or weight loss dominate.',
    clinicalLink:
        'Tachypnea is an early severity marker. Low oxygen saturation, hypotension, confusion, or inability to drink should push escalation.',
    theEthiopianBedside:
        'Ask about indoor smoke exposure, HIV risk, TB contact, malnutrition, vaccination, and distance from care. Chest X-ray may not be immediately available, so clinical severity guides action.',
    survivalPearl:
        'A sick patient with pneumonia needs oxygen assessment before antibiotic debates.',
    curiosityCorner:
        'Rust-colored sputum is classically linked to pneumococcal pneumonia, but real presentations rarely read the textbook.',
    thePlan:
        'Assess severity, give oxygen if hypoxic, start empiric antibiotics by local guidance, hydrate, control fever, and arrange follow-up or admission based on risk.',
    relatedTopics: <String>['Tuberculosis', 'Sepsis', 'Asthma'],
    mnemonics:
        'CURB danger clues: Confusion, Urea high if known, Respiratory rate, Blood pressure.',
  ),
  Article(
    title: 'Tuberculosis',
    category: ['Internal Medicine', 'Infectious Diseases'],
    theEssence:
        '[[Tuberculosis]] is chronic infection with Mycobacterium tuberculosis, most often pulmonary, spread through airborne droplets.',
    theLogic:
        'The immune system walls off bacilli in granulomas, but disease emerges when containment fails. Cavitary lung disease spreads efficiently because coughing aerosolizes organisms.',
    thePortrait:
        'Cough for two or more weeks, fever, night sweats, weight loss, hemoptysis, or contact history. TB can mimic [[Pneumonia]] but usually moves more slowly.',
    clinicalLink:
        'Always think about HIV, malnutrition, diabetes, and household exposure. Extrapulmonary TB can present as lymph nodes, meningitis, pleural effusion, or spinal disease.',
    theEthiopianBedside:
        'Use local TB diagnostic pathways, support adherence, discuss stigma gently, and ask who shares the sleeping space. Treatment interruption risks resistance and community spread.',
    survivalPearl:
        'Chronic cough plus weight loss deserves TB evaluation even if the chest exam is unimpressive.',
    curiosityCorner:
        'Acid-fast staining works because the TB cell wall has waxy mycolic acids that resist ordinary staining.',
    thePlan:
        'Test sputum with available molecular or smear methods, assess HIV status, notify and treat through TB program pathways, screen close contacts, and monitor adherence and toxicity.',
    relatedTopics: <String>['Pneumonia', 'HIV', 'Diabetes'],
    mnemonics:
        'TB symptoms: CANS - Cough, Appetite/weight loss, Night sweats, Slow fever.',
  ),
  Article(
    title: 'Malaria',
    category: ['Internal Medicine', 'Infectious Diseases'],
    theEssence:
        '[[Malaria]] is Plasmodium infection transmitted by Anopheles mosquitoes, with fever plus risk of anemia, hypoglycemia, cerebral disease, and death.',
    theLogic:
        'Parasites invade red cells, rupture them cyclically, and trigger inflammatory fever. Plasmodium falciparum can sequester in microvasculature, causing severe disease.',
    thePortrait:
        'Fever, chills, headache, myalgia, vomiting, pallor, jaundice, or altered mental status. Severe malaria may look like [[Sepsis]], especially in children.',
    clinicalLink:
        'Danger signs include confusion, repeated vomiting, severe anemia, respiratory distress, seizures, hypoglycemia, and shock.',
    theEthiopianBedside:
        'Risk varies by region, altitude, travel, season, bed-net use, and pregnancy. A negative rapid test with strong suspicion may need repeat testing or microscopy depending on setting.',
    survivalPearl:
        'In a febrile patient from a malaria area, check glucose and mental status early; hypoglycemia can be missed.',
    curiosityCorner:
        'The fever pattern reflects synchronized red cell rupture, though real-world fever may be irregular.',
    thePlan:
        'Confirm with rapid diagnostic test or microscopy when possible, classify uncomplicated versus severe, treat according to national guidance, manage glucose, anemia, fluids, and complications.',
    relatedTopics: <String>['Sepsis', 'Anemia', 'Pregnancy'],
    mnemonics:
        'Severe malaria flags: CHARM - Confusion, Hypoglycemia, Anemia, Respiratory distress, Multiple seizures.',
  ),
  Article(
    title: 'Sepsis',
    category: ['Emergency Medicine', 'Infectious Emergencies'],
    theEssence:
        '[[Sepsis]] is life-threatening organ dysfunction from a dysregulated response to infection. It is infection plus failing physiology.',
    theLogic:
        'Inflammation, vasodilation, capillary leak, and microvascular dysfunction reduce tissue oxygen delivery. Shock occurs when circulatory failure persists despite fluids.',
    thePortrait:
        'Fever or hypothermia, tachycardia, tachypnea, confusion, low blood pressure, oliguria, mottled skin, or suspected sources such as [[Pneumonia]], urinary infection, abdominal infection, or [[Malaria]].',
    clinicalLink:
        'Normal temperature does not exclude sepsia. Altered mental status, low urine output, and hypotension are bedside signs of organ dysfunction.',
    theEthiopianBedside:
        'Late presentation is common when transport is difficult. Source control may require early referral if surgery, drainage, or obstetric care is needed.',
    survivalPearl:
        'Treat first-hour sepsis actions as a bundle: oxygen if needed, IV access, fluids for shock, antibiotics, cultures if they do not delay treatment, and source search.',
    curiosityCorner:
        'Sepsis harms partly because the immune response meant to localize infection becomes systemic and injures the host.',
    thePlan:
        'Recognize risk, measure vitals repeatedly, give empiric antibiotics promptly, resuscitate, monitor urine output and mental status, identify source, and escalate when shock or organ dysfunction persists.',
    relatedTopics: <String>['Pneumonia', 'Malaria', 'Diabetic Ketoacidosis'],
    mnemonics:
        'SEPSIS: Suspect infection, Evaluate organs, Pressure low, Start antibiotics, IV fluids, Source control.',
  ),
  Article(
    title: 'Asthma',
    category: ['Internal Medicine', 'Pulmonology'],
    theEssence:
        '[[Asthma]] is variable airway inflammation and bronchoconstriction causing episodic wheeze, cough, chest tightness, and breathlessness.',
    theLogic:
        'Triggers activate inflamed airways, smooth muscle constricts, mucus increases, and airflow becomes limited, especially during expiration.',
    thePortrait:
        'Symptoms vary over time and may worsen at night, with exercise, cold air, smoke, dust, viral illness, or occupational exposures. Severe attacks may have silent chest, exhaustion, or cyanosis.',
    clinicalLink:
        'Differentiate asthma from [[Pneumonia]], heart failure, foreign body, and anaphylaxis. A silent chest in a distressed patient is worse than loud wheeze.',
    theEthiopianBedside:
        'Ask about biomass smoke, inhaler technique, affordability, and whether the patient relies only on relievers. Demonstrating inhaler use is often as important as prescribing.',
    survivalPearl:
        'In acute severe asthma, oxygen, repeated inhaled bronchodilator, steroid, and reassessment are the core moves.',
    curiosityCorner:
        'Wheeze is musical because narrowed airways vibrate as air moves through them.',
    thePlan:
        'Assess severity, treat attacks promptly, identify triggers, teach inhaler technique, provide controller therapy when indicated, and give a written action plan when feasible.',
    relatedTopics: <String>['Pneumonia', 'Anaphylaxis', 'COPD'],
    mnemonics: 'Asthma attack care: O B S - Oxygen, Bronchodilator, Steroid.',
  ),
  Article(
    title: 'Neonatal Jaundice',
    category: ['Pediatrics', 'Neonatology'],
    theEssence:
        '[[Neonatal Jaundice]] is yellow discoloration of the skin and sclera caused by elevated bilirubin in the first weeks of life. It is common and usually benign, but severe cases risk kernicterus.',
    theLogic:
        'Neonates have high red cell turnover and immature liver conjugation, leading to unconjugated bilirubin accumulation. Pathological causes include hemolysis, ABO/Rh incompatibility, sepsis, and metabolic disorders.',
    thePortrait:
        'Yellow skin and sclera appearing within first days of life, poor feeding, lethargy, or high-pitched cry in severe cases. Timing of onset guides whether physiological or pathological.',
    clinicalLink:
        'Connect early jaundice (< 24 hours) with [[Sepsis]] and hemolysis. Late-onset or worsening jaundice needs bilirubin measurement and etiology workup.',
    theEthiopianBedside:
        'Phototherapy availability is limited in many settings. Assess hydration and feeding. Exchange transfusion requires referral. Educate parents on danger signs.',
    survivalPearl:
        'Jaundice in the first 24 hours is always pathological until proven otherwise.',
    curiosityCorner:
        'Bilirubin deposited in the basal ganglia causes kernicterus, an irreversible encephalopathy.',
    thePlan:
        'Assess clinical jaundice, measure bilirubin where possible, check blood group compatibility, manage hydration and feeding, initiate phototherapy per guidelines, and refer for exchange transfusion if needed.',
    relatedTopics: <String>['Sepsis', 'Anemia', 'Neonatal Sepsis'],
    mnemonics: 'Pathological jaundice: FRESH - First 24h, Rapid rise, Elevated conjugated, Sick, Hemolytic signs.',
  ),
  Article(
    title: 'Cardiac Failure',
    category: ['Internal Medicine', 'Cardiology'],
    theEssence:
        '[[Cardiac Failure]] is the inability of the heart to meet the body\'s metabolic demands, causing fluid overload and reduced cardiac output.',
    theLogic:
        'Systolic failure reduces ejection; diastolic failure impairs filling. Both cause backward pressure buildup, leading to pulmonary or peripheral congestion.',
    thePortrait:
        'Dyspnea on exertion or at rest, orthopnea, paroxysmal nocturnal dyspnea, bilateral leg edema, elevated JVP, and basal crackles. Common Ethiopian causes include rheumatic heart disease and [[Hypertension]].',
    clinicalLink:
        'Distinguish left from right failure: left causes pulmonary congestion, right causes peripheral edema and hepatomegaly.',
    theEthiopianBedside:
        'Rheumatic heart disease is a dominant cause in Ethiopia. Ask about prior sore throat illness and joint pain. Medication adherence and dietary salt restriction are key counselling points.',
    survivalPearl:
        'Sitting up, oxygen, and a diuretic are the three core moves for acute pulmonary edema.',
    curiosityCorner:
        'The body compensates with fluid retention and tachycardia, which temporarily maintains output but accelerates deterioration.',
    thePlan:
        'Assess severity with vitals and examination, start diuresis, restrict salt and fluid, optimize cardiac medications, investigate etiology, and manage precipitating factors.',
    relatedTopics: <String>['Hypertension', 'Rheumatic Heart Disease', 'Pneumonia'],
    mnemonics: 'Heart failure symptoms: SOAP - Shortness of breath, Orthopnea, Ankle edema, Poor exercise tolerance.',
  ),
  Article(
    title: 'Preeclampsia',
    category: ['OB/GYN', 'Obstetrics'],
    theEssence:
        '[[Preeclampsia]] is new hypertension after 20 weeks of pregnancy with proteinuria or maternal organ dysfunction.',
    theLogic:
        'Abnormal placentation and endothelial dysfunction cause vasospasm, capillary leak, platelet activation, and reduced perfusion to maternal organs and placenta.',
    thePortrait:
        'High blood pressure, headache, visual symptoms, epigastric pain, swelling, reduced urine, or fetal growth restriction. Seizures mean eclampsia.',
    clinicalLink:
        'Connect [[Hypertension]] in pregnancy with platelets, creatinine, liver enzymes, urine protein, neurologic symptoms, and fetal wellbeing.',
    theEthiopianBedside:
        'Ask gestational age, antenatal care access, danger symptoms, transport options, and prior hypertensive pregnancy. Early referral can be life-saving where magnesium sulfate or operative delivery is limited.',
    survivalPearl:
        'The definitive treatment is delivery, but timing balances maternal danger and fetal maturity.',
    curiosityCorner:
        'The placenta is central: after delivery of placenta, the disease process usually begins to resolve.',
    thePlan:
        'Confirm blood pressure, assess severity, test urine protein and organ markers where available, give antihypertensives for severe pressure, magnesium sulfate for severe features/eclampsia risk, and plan delivery or referral.',
    relatedTopics: <String>['Hypertension', 'Sepsis', 'Pregnancy'],
    mnemonics:
        'Severe features: HEAD - Headache, Eyes blurry, Abdominal pain, Deranged labs.',
  ),
];
