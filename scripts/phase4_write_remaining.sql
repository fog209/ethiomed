-- Phase 4 WRITE (remaining 4): migrate the 4 rows that did not
-- apply from the first full run. Reuses validated convert().
begin;

-- Typhoid Fever
update public.articles
set content = '{"schemaVersion": 2, "sections": [{"key": "definition", "body": "Bacterial systemic infection."}, {"key": "epidemiology", "body": "Endemic in Ethiopia."}, {"key": "etiology", "body": "Salmonella typhi."}, {"key": "pathophysiology", "body": "Peyer''s patch invasion."}, {"key": "clinicalFeatures", "body": "Step-ladder fever, abdominal pain."}, {"key": "diagnosis", "body": "Blood culture, Widal."}, {"key": "treatment", "body": "Ceftriaxone, Ciprofloxacin."}, {"key": "complications", "body": "Bowel perforation."}]}'::jsonb
where id = 'a81546d4-b13f-4293-ae6c-259637d325fc';

-- Bronchial Asthma
update public.articles
set content = '{"schemaVersion": 2, "sections": [{"key": "definition", "body": "Chronic inflammatory disease of the airways causing reversible airflow obstruction."}, {"key": "epidemiology", "body": "Highly prevalent in urban Ethiopia due to dust and pollution."}, {"key": "pathophysiology", "body": "Type 1 hypersensitivity → IgE mediated mast cell degranulation → bronchoconstriction."}, {"key": "clinicalFeatures", "body": "Wheezing, cough, chest tightness, dyspnea."}, {"key": "diagnosis", "body": "Spirometry (FEV1/FVC < 0.7), peak flow monitoring."}, {"key": "treatment", "body": "SABA (Salbutamol) for rescue, ICS (Beclomethasone) for maintenance."}, {"key": "complications", "body": "Status asthmaticus, respiratory failure."}]}'::jsonb
where id = '37291174-71a4-488f-89b8-1f3e34a15346';

-- COPD
update public.articles
set content = '{"schemaVersion": 2, "sections": [{"key": "definition", "body": "Persistent respiratory symptoms and airflow limitation due to airway/alveolar abnormalities."}, {"key": "epidemiology", "body": "Rising in Ethiopia due to indoor biomass fuel smoke (cooking)."}, {"key": "pathophysiology", "body": "Chronic inflammation → lung parenchyma destruction (emphysema) and small airway fibrosis."}, {"key": "clinicalFeatures", "body": "Chronic cough, sputum production, progressive dyspnea."}, {"key": "diagnosis", "body": "Spirometry (post-bronchodilator FEV1/FVC < 0.7)."}, {"key": "treatment", "body": "Smoking cessation, LAMA/LABA inhalers, Oxygen therapy."}, {"key": "complications", "body": "Cor pulmonale, secondary polycythemia."}]}'::jsonb
where id = 'a84caa08-17b2-446e-aaa9-ba1841e2230d';

-- Pneumonia
update public.articles
set content = '{"schemaVersion": 2, "sections": [{"key": "definition", "body": "Infection of the lung parenchyma leading to alveolar consolidation."}, {"key": "epidemiology", "body": "Leading cause of hospital admission in Ethiopia."}, {"key": "pathophysiology", "body": "Pathogen invasion → inflammatory exudate fills alveoli → V/Q mismatch."}, {"key": "clinicalFeatures", "body": "Fever, productive cough, pleuritic chest pain, dullness on percussion."}, {"key": "diagnosis", "body": "Chest X-ray (infiltrates), Sputum culture, CBC (leukocytosis)."}, {"key": "treatment", "body": "Antibiotics (Amoxicillin or Ceftriaxone) based on CURB-65 score."}, {"key": "complications", "body": "Pleural effusion, lung abscess, sepsis."}]}'::jsonb
where id = '82975453-2238-4352-91dd-4c781d461d7e';

commit;
