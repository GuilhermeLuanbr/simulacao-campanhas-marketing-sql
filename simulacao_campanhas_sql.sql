-- estrutura_banco.sql
CREATE SCHEMA IF NOT EXISTS cap15;

CREATE TABLE cap15.dsa_campanha_marketing (
    id SERIAL PRIMARY KEY,
    nome_campanha TEXT NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    orcamento DECIMAL(10,2),
    publico_alvo TEXT,
    canais_divulgacao TEXT,
    tipo_campanha TEXT,
    taxa_conversao DECIMAL(5,2),
    impressoes BIGINT
);

-- procedure_geracao_dados.sql
CREATE OR REPLACE PROCEDURE cap15.inserir_dados_campanha()
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
    randomTarget INT;
    randomConversionRate DECIMAL(5, 2);
    randomImpressions BIGINT;
    randomBudget DECIMAL(10, 2);
    randomChannel VARCHAR(255);
    randomCampaignType VARCHAR(255);
    randomStartDate DATE;
    randomEndDate DATE;
    randomPublicTarget VARCHAR(255);
BEGIN
    LOOP
        EXIT WHEN i > 1000;

        randomTarget := 1 + (i % 5);
        randomConversionRate := ROUND((RANDOM() * 30)::numeric, 2);
        randomImpressions := (1 + FLOOR(RANDOM() * 10)) * 1000000;

        randomBudget := CASE WHEN RANDOM() < 0.8 THEN ROUND((RANDOM() * 100000)::numeric, 2) ELSE NULL END;

        randomChannel := CASE
            WHEN RANDOM() < 0.8 THEN
                CASE FLOOR(RANDOM() * 3)
                    WHEN 0 THEN 'Google'
                    WHEN 1 THEN 'Redes Sociais'
                    ELSE 'Sites de Notícias'
                END
            ELSE NULL
        END;

        randomCampaignType := CASE
            WHEN RANDOM() < 0.8 THEN
                CASE FLOOR(RANDOM() * 3)
                    WHEN 0 THEN 'Promocional'
                    WHEN 1 THEN 'Divulgação'
                    ELSE 'Mais Seguidores'
                END
            ELSE NULL
        END;

        randomStartDate := CURRENT_DATE - (1 + FLOOR(RANDOM() * 1460)) * INTERVAL '1 day';
        randomEndDate := randomStartDate + (1 + FLOOR(RANDOM() * 30)) * INTERVAL '1 day';

        randomPublicTarget := CASE WHEN RANDOM() < 0.2 THEN '?' ELSE 'Publico Alvo ' || randomTarget END;

        INSERT INTO cap15.dsa_campanha_marketing 
        (nome_campanha, data_inicio, data_fim, orcamento, publico_alvo, canais_divulgacao, tipo_campanha, taxa_conversao, impressoes)
        VALUES 
        ('Campanha ' || i, randomStartDate, randomEndDate, randomBudget, randomPublicTarget, randomChannel, randomCampaignType, randomConversionRate, randomImpressions);

        i := i + 1;
    END LOOP;
END;
$$;

-- consultas_exploratorias.sql
-- 1. Total de campanhas por canal
SELECT canais_divulgacao, COUNT(*) FROM cap15.dsa_campanha_marketing GROUP BY canais_divulgacao;

-- 2. Média de taxa de conversão por tipo de campanha
SELECT tipo_campanha, AVG(taxa_conversao) FROM cap15.dsa_campanha_marketing GROUP BY tipo_campanha;

-- 3. Orçamento médio por público alvo
SELECT publico_alvo, AVG(orcamento) FROM cap15.dsa_campanha_marketing WHERE orcamento IS NOT NULL GROUP BY publico_alvo;

-- 4. Impressões totais por ano
SELECT EXTRACT(YEAR FROM data_inicio) AS ano, SUM(impressoes) AS total_impressao
FROM cap15.dsa_campanha_marketing
GROUP BY ano
ORDER BY ano;
