# 🔥 PRÁTICA INTENSIVA DE SUBQUERIES & CONTINUAÇÃO (19/10/2026)

> 📌 **STATUS PARA CONTINUAR NO OUTRO COMPUTADOR:**
> 1. **Já Concluído Hoje:**
>    - Bateria de **4 Exercícios Simples** (1 para cada posição do Guia Mestre: `SELECT`, `FROM`/`LEFT JOIN`, `WHERE`, `HAVING`) + **1 Desafio Completo de Prova** (sem dica de qual subquery usar). **Nota do aluno: 9,8/10!** (Arquivos: `19 10 2026.sql` e seção 2 abaixo).
>    - Destravamento definitivo do **`GROUP BY` dentro da Subquery do `HAVING`** (Regra do Espelho + Mapa de Onde Mora Cada ID).
>    - Destravamento da **Vigência Temporal (`TRE_META` $\leftrightarrow$ `TRE_RECORD`)** no Exercício 2 da Rodada Rápida (Por que filtrar `BETWEEN` antes do `MAX`).
> 2. **Onde Paramos Exatamente (Para Continuar Agora):**
>    - **Rodada Rápida (Abaixo na Seção 3):** Falta enviar o código do **Exercício 1 (`DELETE` com `NOT IN`)** e do **Exercício 3 (`UPDATE` com Subquery)** (se quiser finalizar).
>    - **PRÓXIMA ETAPA JÁ COMBINADA (Seção 4):** Praticar as **Procedures de Maior/Menor** (Padrão do Trio do Professor: `Procedure V1` com Subquery no `FROM` + `Function` + `Procedure V2` usando a Function, além de Maior/Menor por Categoria).

---

## 🧠 1. Os 3 Grandes "Cliques" (Insights) da Sessão de Hoje

### 1.1 Na Subquery do `HAVING`, como saber qual deve ser o `ID` agrupador? (A Regra do Espelho)
* **Regra de Ouro:** O `ID` que vai no `GROUP BY` **dentro** da subquery do `HAVING` é sempre o **ESPELHO (a mesma entidade)** que você agrupou no `GROUP BY` **lá fora**!
* **Por quê?** Porque se lá fora você montou caixas por **Exercício** (`GROUP BY e.COD_EXERCICIO, e.NOME`), a subquery do `HAVING` precisa montar exatamente as mesmas caixas por **Exercício** (`GROUP BY e2.COD_EXERCICIO` ou `it2.ID_EXERCICIO`) para descobrir qual é a maior média entre os exercícios (`MAX(AVG(...))`).

### 1.2 Por que na Subquery do `HAVING` não basta fazer `FROM TRE_SERIE S GROUP BY ...`? (Onde Mora Cada ID)
* Na tabela `TRE_SERIE` moram apenas `ID_SERIE`, `ID_ITEM_TREINO`, `COD_SERIE`, `NUMERO_SERIE`, `REPETICOES` e `CARGA`.
* **NÃO existe `ID_EXERCICIO`, nem `ID_TREINO`, nem `ID_USUARIO` dentro de `TRE_SERIE`!**
* E se agrupar por `S.ID_ITEM_TREINO`, dá errado porque cada dia que alguém faz Supino gera um `ID_ITEM_TREINO` diferente (você calcularia a média daquele dia específico, e não a média geral do exercício no banco todo).
* **Por isso:** Dentro da subquery do `HAVING`, você também precisa **percorrer o caminho de `INNER JOIN`s até chegar na tabela que tem o `ID` do `GROUP BY`**!
  * **Macete de Prova:** Basta copiar os mesmos `FROM ... INNER JOIN ...` da consulta de cima e colar dentro da subquery do `HAVING`!

```
[TRE_SERIE s] (Tem: CARGA, REPETICOES, ID_ITEM_TREINO)
      │
      ▼  (Precisa agrupar por EXERCÍCIO ou TREINO? Sobe 1 degrau!)
[TRE_ITEM_TREINO it] ──► Aqui moram o ID_EXERCICIO e o ID_TREINO!
      │
      ├──► (Precisa agrupar por USUÁRIO? Sobe mais 1 degrau p/ TRE_TREINO!)
      │    [TRE_TREINO t] ──► Aqui mora o ID_USUARIO!
      │
      └──► (Precisa agrupar por GRUPO MUSCULAR? Sobe mais 1 degrau p/ TRE_EXERCICIO!)
           [TRE_EXERCICIO e] ──► Aqui mora o ID_GRP_MUSCULAR!
```

### 1.3 Por que na Vigência Temporal (`TRE_META` $\leftrightarrow$ `TRE_RECORD`) o `BETWEEN` tem que vir ANTES do `MAX()`?
* O Usuário 1 (Lucas) tem **4 recordes históricos** para o Exercício 1 (Supino):
  * `REC-001` (`80kg` em Jan), `REC-002` (`90kg` em Mar), `REC-003` (`100kg` em Mai — durante a `META-001`) e `REC-004` (`102,5kg` em Set — já durante a `META-002`).
* **O Erro:** Se você criar uma subquery no `LEFT JOIN` que faz `MAX(R.CARGA_RECORD)` olhando apenas `TRE_RECORD` sem filtrar a data da meta primeiro, o banco crava que o maior recorde do Lucas é **`102,5kg` (de Setembro)**. Aí, quando você tenta filtrar `WHERE DATA_RECORD BETWEEN M.DATA_CRIACAO AND ...` lá fora, o Oracle vê que Setembro está fora da `META-001` (Jan a Mai) e **joga a `META-001` no lixo**, em vez de mostrar o recorde de **`100kg`** que ele bateu em Maio! Além disso, o `WHERE` externo elimina todas as metas que têm `0` recordes.
* **A Solução (2 Jeitos Perfeitos):**
  * **Jeito 1 (Estratégia do Aluno — Montar a Subquery Completa e Encapsular no `LEFT JOIN`):** Coloque a `TRE_META M2` **dentro** da subquery junto com `TRE_RECORD R`, filtre o `WHERE R.DATA_RECORD BETWEEN M2.DATA_CRIACAO AND NVL(M2.DATA_CONCLUSAO, SYSDATE)` **lá dentro** antes do `MAX`, agrupe por `M2.ID_META`, e lá fora ligue `ON RES_REC.ID_META = M.ID_META`!
  * **Jeito 2 (Subquery no `SELECT`):** Como a subquery no `SELECT` enxerga a tabela `M` de fora, faça o `SELECT MAX(R.CARGA_RECORD)` com o `WHERE R.DATA_RECORD BETWEEN M.DATA_CRIACAO AND NVL(M.DATA_CONCLUSAO, SYSDATE)` direto dentro da coluna do `SELECT`.

---

## ✅ 2. Bateria 1 Resolvida pelo Aluno e Corrigida (Nota: 9,8/10)

### Questão 1 — Subquery no `SELECT`
> **Enunciado:** Identificou-se a necessidade de gerar uma listagem rápida contendo o nome de todos os grupos musculares cadastrados e, ao lado de cada um, uma coluna mostrando a quantidade total de exercícios pertencentes àquele grupo e outra coluna mostrando a maior carga de recorde já batida em exercícios daquele grupo (exibindo `0` caso não haja nenhum recorde). Resolva utilizando subqueries na cláusula `SELECT`.

```sql
SELECT 
    GRP.NOME,
    (SELECT COUNT(*) FROM TRE_EXERCICIO E WHERE E.ID_GRP_MUSCULAR = GRP.ID_GRP_MUSCULAR) AS TOTAL_EXER,
    -- Ajuste fino: envolver com NVL(..., 0) para exibir 0 quando não houver recorde no grupo:
    NVL((SELECT MAX(R.CARGA_RECORD)
         FROM TRE_RECORD R
         INNER JOIN TRE_EXERCICIO E ON R.ID_EXERCICIO = E.ID_EXERCICIO
         WHERE E.ID_GRP_MUSCULAR = GRP.ID_GRP_MUSCULAR), 0) AS MAIOR_RECORD
FROM TRE_GRUPOMUSCULAR GRP;
```

### Questão 2 — Subquery no `FROM` / `LEFT JOIN` (10/10!)
> **Enunciado:** Constatou-se que o relatório de alunos precisa exibir o código e o nome de todos os usuários do sistema (mesmo os que nunca treinaram) acompanhados da quantidade de treinos realizados e da soma total de minutos treinados por cada um (exibindo `0` quando não houver treinos). Resolva obrigatoriamente utilizando uma subquery na cláusula `FROM` (ou `LEFT JOIN`) sem usar `GROUP BY` na consulta externa.

```sql
-- Estratégia matadora usada pelo aluno: montar a subquery toda primeiro e depois encapsular!
SELECT
    U.COD_USUARIO,
    U.NOME,
    NVL(RES.TOTAL_TREINO, 0) AS TOTAL_TREINO,
    NVL(RES.TOTAL_MINUTOS, 0) AS TOTAL_MINUTOS
FROM TRE_USUARIO U
LEFT JOIN (
    SELECT
        U.ID_USUARIO,
        COUNT(T.ID_TREINO) AS TOTAL_TREINO,
        SUM(T.DURACAO_MINUTO) AS TOTAL_MINUTOS
    FROM TRE_USUARIO U
    INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
    GROUP BY U.ID_USUARIO
) RES ON RES.ID_USUARIO = U.ID_USUARIO;
```

### Questão 3 — Subquery no `WHERE` (10/10!)
> **Enunciado:** Descobriu-se necessária uma consulta para identificar quem estabeleceu a meta mais ambiciosa da academia. Exiba o nome do usuário, o nome do exercício, o status da meta e o valor da carga-alvo apenas da(s) meta(s) que possuir(em) a maior carga-alvo registrada em todo o sistema.

```sql
SELECT 
    U.NOME,
    E.NOME,
    M.STATUS,
    M.CARGA_ALVO
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON M.ID_USUARIO = U.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON E.ID_EXERCICIO = M.ID_EXERCICIO
WHERE M.CARGA_ALVO = (SELECT MAX(M.CARGA_ALVO) FROM TRE_META M);
```

### Questão 4 — Subquery no `HAVING` (10/10!)
> **Enunciado:** Identificou-se a necessidade de descobrir qual exercício possui a maior média de repetições por série em toda a academia. Exiba o código do exercício, o nome do exercício e a sua média de repetições (arredondada em 2 casas decimais) apenas para o exercício campeão nessa média geral.

```sql
SELECT 
    E.COD_EXERCICIO,
    E.NOME,
    ROUND(AVG(S.REPETICOES), 2) AS MEDIA_REP
FROM TRE_EXERCICIO E
INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_EXERCICIO = E.ID_EXERCICIO
INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
GROUP BY E.COD_EXERCICIO, E.NOME
HAVING AVG(S.REPETICOES) = (
    SELECT MAX(AVG(S.REPETICOES))
    FROM TRE_SERIE S
    INNER JOIN TRE_ITEM_TREINO IT ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
    INNER JOIN TRE_EXERCICIO E ON IT.ID_EXERCICIO = E.ID_EXERCICIO
    GROUP BY E.COD_EXERCICIO
);
```

### Questão 5 — O Desafio Completo Sem Dica (9,5/10!)
> **Enunciado:** Constatou-se que a coordenação da academia precisa de um painel comparativo de metas ativas para avaliar se os alunos já bateram suas metas durante os treinos sem perceber. Elabore uma consulta SQL que liste, **apenas para os usuários que já realizaram pelo menos um treino registrado no histórico da academia**:
> 1. O nome do usuário;
> 2. O nome do exercício da meta;
> 3. A carga-alvo da meta;
> 4. A maior carga já levantada por esse usuário **em séries desse mesmo exercício** (caso ele nunca tenha feito séries desse exercício específico, exiba `0`);
> 5. A diferença numérica entre a carga-alvo da meta e essa maior carga levantada nas séries (`CARGA_ALVO - MAIOR_CARGA_SERIE`).
> **Regra de filtragem:** A consulta deve considerar apenas as metas cujo status seja `'ATIVA'` e cuja carga-alvo seja estritamente maior do que a média geral de carga-alvo de todas as metas cadastradas no sistema.

```sql
SELECT
    U.NOME,
    E.NOME,
    M.CARGA_ALVO,
    NVL(MAX_CARGA.MAIOR_CARGA, 0) AS MAIOR_CARGA,
    -- Ajuste fino: colocar NVL também dentro da subtração (senão 100 - NULL vira NULL!):
    (M.CARGA_ALVO - NVL(MAX_CARGA.MAIOR_CARGA, 0)) AS DIF_NUM
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON U.ID_USUARIO = M.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON M.ID_EXERCICIO = E.ID_EXERCICIO
LEFT JOIN ( 
    SELECT 
        U.ID_USUARIO,
        IT.ID_EXERCICIO,
        MAX(S.CARGA) AS MAIOR_CARGA
    FROM TRE_USUARIO U
    INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
    INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_TREINO = T.ID_TREINO
    INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
    GROUP BY U.ID_USUARIO, IT.ID_EXERCICIO
) MAX_CARGA ON MAX_CARGA.ID_USUARIO = U.ID_USUARIO
           AND MAX_CARGA.ID_EXERCICIO = E.ID_EXERCICIO
WHERE M.STATUS = 'ATIVA' 
  AND M.CARGA_ALVO > (SELECT AVG(M.CARGA_ALVO) FROM TRE_META M)
  AND (SELECT COUNT(ID_TREINO) FROM TRE_TREINO WHERE ID_USUARIO = U.ID_USUARIO) >= 1;
```

---

## ⚡ 3. Rodada Rápida: DML com Subqueries & Vigência Temporal (Em Andamento)

### Exercício 1: Limpeza de Dados Órfãos (`DELETE` com Subquery) — *[Pendente fazer no outro PC]*
> **Enunciado:** Identificou-se a necessidade de realizar uma faxina no catálogo da academia, removendo exercícios que foram cadastrados mas nunca foram utilizados na prática. Elabore um comando `DELETE` que apague da tabela de exercícios todos os registros que **jamais** apareceram em nenhum item de treino E que **também jamais** tiveram nenhuma meta registrada para eles. *(Lembre-se da proteção obrigatória contra valores nulos ao usar `NOT IN`!).*

### Exercício 2: Auditoria Temporal de Metas (`SELECT` com `TRE_META` $\leftrightarrow$ `TRE_RECORD`) — *[Resolvido e Discutido Hoje!]*
> **Enunciado:** Constatou-se que alguns alunos batem recordes pessoais durante o período de vigência de uma meta sem atualizar o painel. Elabore uma consulta SQL que exiba o código da meta, o nome do usuário, o nome do exercício, a carga-alvo da meta e uma coluna calculada chamada `MAIOR_RECORD_VIGENCIA` contendo o maior recorde batido por aquele mesmo aluno, naquele mesmo exercício, **exclusivamente dentro do período de vigência da meta** (ou seja, a data do recorde deve estar entre a data de criação da meta e a data de conclusão da meta — caso a data de conclusão seja nula, considere a data atual do sistema `SYSDATE` como limite final). Exiba `0` caso não haja recordes no período.

**Solução 1 (Com `LEFT JOIN` encapsulando `TRE_META` + `TRE_RECORD`):**
```sql
SELECT
    M.COD_META,
    U.NOME,
    E.NOME AS EXERCICIO,
    M.CARGA_ALVO,
    NVL(RES_REC.MAIOR_REC, 0) AS MAIOR_RECORD_VIGENCIA,
    M.DATA_CRIACAO,
    NVL(M.DATA_CONCLUSAO, SYSDATE) AS LIMITE_VIGENCIA
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON M.ID_USUARIO = U.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON M.ID_EXERCICIO = E.ID_EXERCICIO
LEFT JOIN (
    SELECT
        M2.ID_META,
        MAX(R.CARGA_RECORD) AS MAIOR_REC
    FROM TRE_META M2
    INNER JOIN TRE_RECORD R ON R.ID_USUARIO = M2.ID_USUARIO
                           AND R.ID_EXERCICIO = M2.ID_EXERCICIO
    WHERE R.DATA_RECORD BETWEEN M2.DATA_CRIACAO AND NVL(M2.DATA_CONCLUSAO, SYSDATE)
    GROUP BY M2.ID_META
) RES_REC ON RES_REC.ID_META = M.ID_META;
```

**Solução 2 (Com Subquery direto no `SELECT`):**
```sql
SELECT
    M.COD_META,
    U.NOME,
    E.NOME AS EXERCICIO,
    M.CARGA_ALVO,
    NVL((
        SELECT MAX(R.CARGA_RECORD)
        FROM TRE_RECORD R
        WHERE R.ID_USUARIO = M.ID_USUARIO
          AND R.ID_EXERCICIO = M.ID_EXERCICIO
          AND R.DATA_RECORD BETWEEN M.DATA_CRIACAO AND NVL(M.DATA_CONCLUSAO, SYSDATE)
    ), 0) AS MAIOR_RECORD_VIGENCIA
FROM TRE_USUARIO U
INNER JOIN TRE_META M ON M.ID_USUARIO = U.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON M.ID_EXERCICIO = E.ID_EXERCICIO;
```

### Exercício 3: Fechamento Automático de Metas (`UPDATE` em Conjunto com Subquery) — *[Pendente fazer no outro PC]*
> **Enunciado:** Descobriu-se necessária uma rotina de atualização em lote para concluir automaticamente as metas que já foram atingidas nos treinos. Elabore um único comando `UPDATE` na tabela de metas que altere o `STATUS` para `'CONCLUIDA'` e preencha a `DATA_CONCLUSAO` com `TRUNC(SYSDATE)` apenas para as metas que atualmente estão com status `'ATIVA'` e cuja `CARGA_ALVO` seja **menor ou igual** à maior carga já registrada pelo respectivo usuário naquele mesmo exercício na tabela de recordes (`TRE_RECORD`).

---

## 🏆 4. PRÓXIMO PASSO NO OUTRO COMPUTADOR: Procedures de Maior/Menor (Padrão `ATV_GRUPO.sql`)

Assim que abrir no outro computador, depois de fechar os Exercícios 1 e 3 acima (ou direto, se preferir), vamos praticar **Procedures de Maior/Menor** com Subquery no `FROM`:
1. **Procedure V1 (Pura com Subquery no `FROM` + `GROUP BY` + Desempate com `MIN(ID)`):** Descobrindo o maior/menor valor e buscando o ID do dono.
2. **Function Auxiliar (Por `COD_`):** Recebendo o `P_COD_...` e retornando a contagem/soma/média.
3. **Procedure V2 (Consumindo a Function na Subquery do `FROM`):** O molde clássico do `ATV_GRUPO.sql` do professor!
