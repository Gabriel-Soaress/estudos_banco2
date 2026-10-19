--Enunciado: Identificou-se a necessidade de gerar uma listagem rápida contendo o nome 
--de todos os grupos musculares cadastrados e, ao lado de cada um, uma coluna mostrando 
--a quantidade total de exercícios pertencentes àquele grupo e outra coluna mostrando a maior 
--carga de recorde já batida em exercícios daquele grupo 
--(exibindo 0 caso não haja nenhum recorde). Resolva utilizando subqueries na cláusula SELECT.

SELECT 
    GRP.NOME,
    (SELECT COUNT(*) FROM TRE_EXERCICIO E WHERE E.ID_GRP_MUSCULAR =  GRP.ID_GRP_MUSCULAR)AS TOTAL_EXER,
    (SELECT
        MAX(R.CARGA_RECORD)
    FROM TRE_RECORD R
    INNER JOIN TRE_EXERCICIO E ON R.ID_EXERCICIO = E.ID_EXERCICIO
    WHERE E.ID_GRP_MUSCULAR =  GRP.ID_GRP_MUSCULAR) AS MAIOR_RECORD
FROM TRE_GRUPOMUSCULAR GRP;

--OK, SEM PROBLEMAS!


--Enunciado: Constatou-se que o relatório de alunos precisa exibir o 
--código e o nome de todos os usuários do sistema (mesmo os que nunca treinaram) 
--acompanhados da quantidade de treinos realizados e da soma total de minutos 
--treinados por cada um (exibindo 0 quando não houver treinos). Resolva obrigatoriamente 
--utilizando uma subquery na cláusula FROM (ou LEFT JOIN) sem usar GROUP BY na consulta externa.
SELECT
    U.COD_USUARIO,
    U.NOME,
    NVL(RES.TOTAL_TREINO,0),
    NVL(TOTAL_MINUTOS,0)
FROM TRE_USUARIO U
LEFT JOIN (SELECT
                U.ID_USUARIO,
                COUNT(T.ID_TREINO) AS TOTAL_TREINO,
                SUM(T.DURACAO_MINUTO) AS TOTAL_MINUTOS
            FROM TRE_USUARIO U
            INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
            GROUP BY U.ID_USUARIO)RES ON RES.ID_USUARIO = U.ID_USUARIO;
            
--OK, USEI A ESTRATEGIA DE MONTAR A SUBQUERY TODA PRIMEIRO E DPS ENCAPSULAR


--Enunciado: Descobriu-se necessária uma consulta para identificar quem estabeleceu a meta
--mais ambiciosa da academia. Exiba o nome do usuário, o nome do exercício, 
--o status da meta e o valor da carga-alvo apenas da(s) meta(s) que possuir(em) 
--a maior carga-alvo registrada em todo o sistema.

SELECT 
    U.NOME,
    E.NOME,
    M.STATUS,
    M.CARGA_ALVO
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON M.ID_USUARIO = U.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON E.ID_EXERCICIO = M.ID_EXERCICIO
WHERE M.CARGA_ALVO = (SELECT MAX(M.CARGA_ALVO) FROM TRE_META M);

--OK TAMBÉM

--Enunciado: Identificou-se a necessidade de descobrir qual exercício possui 
--a maior média de repetições por série em toda a academia. 
--Exiba o código do exercício, o nome do exercício e a sua média de repetições 
--(arredondada em 2 casas decimais) apenas para o exercício campeão nessa média geral.

SELECT 
    E.COD_EXERCICIO,
    E.NOME,
    ROUND(AVG(S.REPETICOES),2)
FROM TRE_EXERCICIO E
INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_EXERCICIO = E.ID_EXERCICIO
INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
GROUP BY E.COD_EXERCICIO,E.NOME
HAVING AVG(S.REPETICOES) = (SELECT
                                MAX(AVG(S.REPETICOES))
                            FROM TRE_SERIE S
                            INNER JOIN TRE_ITEM_TREINO IT ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
                            INNER JOIN TRE_EXERCICIO E ON IT.ID_EXERCICIO = E.ID_EXERCICIO
                            GROUP BY E.COD_EXERCICIO
                            );
    

/*Constatou-se que a coordenação da academia precisa de um painel comparativo de
metas ativas para avaliar se os alunos já bateram suas metas durante os treinos sem perceber.
Elabore uma consulta SQL que liste, apenas para os usuários que já realizaram 
pelo menos um treino registrado no histórico da academia:

O nome do usuário;

O nome do exercício da meta;

A carga-alvo da meta;

A maior carga já levantada por esse usuário em séries desse mesmo exercício 
(caso ele nunca tenha feito séries desse exercício específico, exiba 0);

A diferença numérica entre a carga-alvo da meta e essa maior carga levantada nas 
séries (CARGA_ALVO - MAIOR_CARGA_SERIE).

Regra de filtragem: A consulta deve considerar apenas as metas cujo 
status seja 'ATIVA' e cuja carga-alvo seja estritamente maior do que
a média geral de carga-alvo de todas as metas cadastradas no sistema.*/


SELECT
    U.NOME,
    E.NOME,
    M.CARGA_ALVO,
    NVL(MAX_CARGA.MAIOR_CARGA,0) AS MAIOR_CARGA,
    (M.CARGA_ALVO - MAX_CARGA.MAIOR_CARGA) AS DIF_NUM
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON U.ID_USUARIO = M.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON M.ID_EXERCICIO = E.ID_EXERCICIO
LEFT JOIN( 
    SELECT 
        U.ID_USUARIO,
        IT.ID_EXERCICIO,
        MAX(S.CARGA) AS MAIOR_CARGA
    FROM TRE_USUARIO U
    INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
    INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_TREINO = T.ID_TREINO
    INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
    GROUP BY U.ID_USUARIO,IT.ID_EXERCICIO)MAX_CARGA ON MAX_CARGA.ID_USUARIO = U.ID_USUARIO
                                                    AND MAX_CARGA.ID_EXERCICIO = E.ID_EXERCICIO
WHERE M.STATUS = 'ATIVA' AND M.CARGA_ALVO > (SELECT AVG(M.CARGA_ALVO) FROM TRE_META M)
AND (SELECT COUNT(ID_TREINO) FROM TRE_TREINO WHERE ID_USUARIO = U.ID_USUARIO) >= 1;


COMMIT;
            