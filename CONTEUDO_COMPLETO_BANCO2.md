# 📘 ENCICLOPÉDIA COMPLETA DE BANCO DE DADOS II (ORACLE SQL & PL/SQL)
> **Documento Mestre Unificado:** Todo o conteúdo didático, mapas mentais, diagramas, analogias, regras de negócio e exemplos completos dos Dias 1, 2, 3 e 4 em um único lugar, sem cortes e sem resumos.  
> **Regras Absolutas da Disciplina:** ❌ Proibido `WITH` (CTEs) | ❌ Proibido `UNION` / `UNION ALL` | ❌ Proibido Bloco `EXCEPTION`.

---

## 🧭 ÍNDICE GERAL
* **[PARTE 1: ARQUITETURA DO BANCO, ANTI-PRODUTO CARTESIANO E SUBQUERIES (DIA 1)](#parte-1-arquitetura-do-banco-anti-produto-cartesiano-e-subqueries-dia-1)**
  * 1.1 O Mapa Mental do Banco `TRE_` e a Pegadinha do `ID_USUARIO`
  * 1.2 O que é o Produto Cartesiano e por que ele destrói sua consulta
  * 1.3 Subquery no `SELECT` (A Célula do Excel e a Chamada Escolar)
  * 1.4 Subquery no `FROM` (A View Temporária / Post-It, o Crachá e o Método em 3 Passos)
  * 1.5 Regras de Ouro das Subqueries no `FROM` (Ilha Isolada e Proibição de Vírgula)
  * 1.6 A Tabela `DUAL` (A Esteira de Fábrica de Uma Linha)
  * 1.7 Funções de Tratamento de Nulos e Textos (`NVL`, `COALESCE`, `UPPER`)
  * **1.8 🔥 GUIA MESTRE DAS SUBQUERIES: O Que Muda no `SELECT`, no `FROM`/`JOIN`, no `WHERE` e no `HAVING`?**
* **[PARTE 2: GROUP BY, HAVING, EXTREMOS, FUNÇÕES NUMÉRICAS E VIEWS (DIA 2)](#parte-2-group-by-having-extremos-funções-numéricas-e-views-dia-2)**
  * 2.1 A Regra de Ouro do `GROUP BY` (A Analogia das Caixas de Papelão Lacradas)
  * 2.2 `WHERE` vs `HAVING` (A Peneira Grossa vs O Controle de Qualidade)
  * 2.3 Como Pescar o "Dono" do Maior ou Menor Valor (`MAX` e `MIN` com Subqueries)
  * 2.4 Por que não posso usar `MAX(AVG)` direto sem Subquery no `HAVING`? (A Sala de Aula)
  * 2.5 Funções Auxiliares Numéricas (`ROUND`, `TRUNC`, `NULLIF`)
  * 2.6 `VIEWS` Analíticas: Do "Post-it" ao "Caderno de Receitas Definitivo"
* **[PARTE 3: PROCEDURES, PARÂMETROS (IN, OUT, IN OUT), DML ANINHADO E OPERADORES (DIA 3)](#parte-3-procedures-parâmetros-in-out-in-out-dml-aninhado-e-operadores-dia-3)**
  * 3.1 O que é uma `PROCEDURE` e a Regra do `SELECT ... INTO` (Balde e Cadeira Única)
  * 3.2 Desmistificando os Parâmetros: `IN`, `OUT` e `IN OUT` (A Analogia dos Envelopes)
  * 3.3 Exemplo Real Completo de `PROCEDURE` + Bloco Anônimo de Teste (`DECLARE ... BEGIN ... END`)
  * 3.4 Regra Inegociável: Por que `OUT` e `IN OUT` DEVEM ser Variáveis de Memória (`PLS-00363`)
  * 3.5 Operadores de Conjunto no SQL: `IN` (Lista VIP) e `NOT IN` (Lista Negra + Armadilha do `NULL`)
  * 3.6 Subqueries em Comandos DML (`UPDATE`, `UPDATE` Multinível com `CASE`, `INSERT ... SELECT`, `DELETE`)
  * 3.7 O Contador Secreto do Oracle: `SQL%ROWCOUNT`
* **[PARTE 4: FUNCTIONS NO SELECT, %ROWTYPE, VIGÊNCIA TEMPORAL E MODULARIZAÇÃO (DIA 4)](#parte-4-functions-no-select-rowtype-vigência-temporal-e-modularização-dia-4)**
  * 4.1 A Batalha Definitiva: `PROCEDURE` vs `FUNCTION`
  * 4.2 Por que apenas a `FUNCTION` entra no `SELECT` e por que ela não aceita `OUT` nem DML
  * 4.3 Anatomia Completa de uma `FUNCTION` e Controle de Fluxo sem `EXCEPTION` (O `ELSE` no `CASE`)
  * 4.4 O Casamento entre Meta, Recorde e Série (A Linha do Tempo da Vigência Temporal)
  * 4.5 O Super Poder do `%ROWTYPE` (A Maleta de Ferramentas e a Caixa de Ovos sem `*`)
  * 4.6 Modularização Nível Prova: `PROCEDURE` Consumindo `FUNCTION` dentro do `UPDATE` (A Esteira Rolante)

---
---

# PARTE 1: ARQUITETURA DO BANCO, ANTI-PRODUTO CARTESIANO E SUBQUERIES (DIA 1)

## 1.1 O Mapa Mental do seu Banco: Como as Tabelas se Conectam de Verdade

Antes de escrever qualquer código, você precisa enxergar o caminho exato que o dado percorre no banco `TRE_`:

```
[TRE_USUARIO] 
      │ (1:N - cria treinos)
      ▼
[TRE_TREINO] 
      │ (1:N - adiciona exercícios ao treino)
      ▼
[TRE_ITEM_TREINO] ─── (N:1) ──► [TRE_EXERCICIO] ─── (N:1) ──► [TRE_GRUPOMUSCULAR]
      │
      │ (1:N - faz repetições e bota peso)
      ▼
 [TRE_SERIE] (onde a CARGA e as REPETIÇÕES realmente existem!)
```

E em paralelo, ligadas diretamente ao Usuário e ao Exercício, temos as tabelas de acompanhamento:
* **`TRE_META`**: Guarda a carga alvo que o usuário quer atingir em um exercício (`ID_USUARIO`, `ID_EXERCICIO`, `CARGA_ALVO`, `DATA_CRIACAO`, `DATA_ALVO`, `DATA_CONCLUSAO`, `STATUS`).
* **`TRE_RECORD`**: Guarda o histórico de recordes batidos pelo usuário em um exercício (`ID_USUARIO`, `ID_EXERCICIO`, `CARGA_RECORD`, `DATA_RECORD`).

> ⚠️ **PEGADINHA CLÁSSICA DE PROVA NO SEU BANCO:**  
> A tabela `TRE_EXERCICIO` possui uma coluna chamada `ID_USUARIO`. **Cuidado!** Aquilo serve apenas para registrar qual usuário cadastrou/criou um exercício personalizado no aplicativo (ex: Gabriel cadastrou o *Agachamento Búlgaro*). Isso **NÃO** significa que ele treinou aquele exercício!  
> Para saber se o aluno realmente treinou e levantou peso, o único caminho verdadeiro é:  
> **`TRE_USUARIO` $\rightarrow$ `TRE_TREINO` $\rightarrow$ `TRE_ITEM_TREINO` $\rightarrow$ `TRE_SERIE`**.

---

## 1.2 O que é o Produto Cartesiano e por que ele destrói sua consulta?

* **A Analogia das Pizzas:**  
  Se você tem uma lista com 3 amigos e uma lista com 4 sabores de pizza, e cruzar as duas sem regra de ligação correta, o resultado terá $3 \times 4 = 12$ linhas. Isso é multiplicar tudo por tudo.
* **O Perigo Real no Banco (O Cruzamento de Tabelas Filhas 1:N no mesmo nível):**  
  Imagine a seguinte situação real no banco:
  - O Lucas tem **3 metas** cadastradas no Supino (`TRE_META`).
  - O Lucas tem **4 recordes** batidos no Supino (`TRE_RECORD`).
  - O Lucas fez **10 séries** de Supino (`TRE_SERIE`).  
  
  Se você fizer um `JOIN` direto entre essas três tabelas filhas na mesma consulta principal:  
  O banco vai multiplicar $3 \times 4 \times 10 = \mathbf{120 \text{ linhas!}}$  
  Cada série vai se repetir 12 vezes. Se você aplicar um `SUM(CARGA)` ou um `COUNT(*)`, seu resultado ficará multiplicado por 12, completamente errado, e o professor zera a questão.

---

## 1.3 FORMA 1 de Evitar o Produto Cartesiano: Subquery no `SELECT` (A Célula do Excel)

* **A Analogia da Célula do Excel:**  
  Em uma planilha do Excel, dentro de um único quadradinho (célula) de uma linha, você só consegue colocar **um único valor** (um número, um texto ou uma data). Você nunca consegue enfiar uma tabela inteira de 10 linhas e 3 colunas dentro de um único quadradinho.
* **Como o Banco Pensa:**  
  Quando você coloca um `(SELECT ...)` no lugar de uma coluna do seu `SELECT` principal, o Oracle exige que aquela subconsulta devolva **estritamente 1 linha e 1 coluna** para caber na célula daquela linha! Se devolver mais de uma linha, o Oracle estoura o erro `ORA-01427: single-row subquery returns more than one row`.

```sql
SELECT 
    u.NOME,
    -- Subquery 1: devolve 1 número único para a célula de metas daquele usuário
    (SELECT COUNT(*) FROM TRE_META m WHERE m.ID_USUARIO = u.ID_USUARIO) AS TOTAL_METAS,
    -- Subquery 2: devolve 1 número único para a célula de recordes daquele usuário
    (SELECT COUNT(*) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) AS TOTAL_RECORDES
FROM TRE_USUARIO u;
```

* **Por que essa consulta não repete o mesmo número para todo mundo? (A Analogia da Chamada Escolar):**
  * Se a subquery não tivesse o filtro `WHERE m.ID_USUARIO = u.ID_USUARIO`, seria como o professor perguntar para a sala inteira: *"Quantas metas existem na academia toda?"*. Ele perguntaria isso 10 vezes e escreveria o mesmo número total na frente do nome de cada aluno.
  * Mas como colocamos a amarração **`WHERE m.ID_USUARIO = u.ID_USUARIO`**, torna-se uma **pergunta individualizada (correlacionada)**: o professor olha para a linha do **Lucas** (`u.ID_USUARIO = 1`) e pergunta *"quantas metas VOCÊ tem?"* (responde 3). Depois desce para a linha do **Gabriel** (`u.ID_USUARIO = 2`) e pergunta *"quantas metas VOCÊ tem?"* (responde 2).
* **E quando a Subquery no `SELECT` precisa de uma tabela ponte?**  
  Se a consulta principal está na tabela `TRE_TREINO t` e você quer contar quantas séries (`TRE_SERIE`) existem naquele treino, a tabela `TRE_SERIE` não tem a coluna `ID_TREINO` direta — quem tem é a tabela intermediária `TRE_ITEM_TREINO`. Basta fazer o `INNER JOIN` dentro da própria subquery:
  ```sql
  SELECT
      t.COD_TREINO,
      (SELECT COUNT(s.ID_SERIE)
       FROM TRE_SERIE s
       INNER JOIN TRE_ITEM_TREINO it ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
       WHERE it.ID_TREINO = t.ID_TREINO) AS TOTAL_SERIES_DO_TREINO
  FROM TRE_TREINO t;
  ```

---

## 1.4 FORMA 2 de Evitar o Produto Cartesiano: Subquery no `FROM` (A View Temporária / Post-It)

> 💡 **O MAIOR ATALHO MENTAL DE BANCO DE DADOS II:**  
> Como o seu professor proibiu o uso de `WITH` (CTEs), **toda vez que você precisar agrupar ou resumir uma tabela antes de fazer `JOIN` com outras tabelas, você usará uma Subquery no `FROM` (chamada de Tabela Derivada ou *Inline View*)!**

* **A Analogia do Caderno Fixo vs Post-it Temporário:**
  * Uma **`VIEW` comum** (`CREATE OR REPLACE VIEW vw_nome AS ...`) é uma receita anotada no seu **caderno fixo**: ela fica gravada permanentemente no banco de dados.
  * Uma **Subquery no `FROM`** é um **Post-it temporário**: você escreve um `SELECT` entre parênteses direto na cláusula `FROM` ou `JOIN`, dá um apelido para ele, usa os dados resumidos naquela consulta e, assim que o resultado aparece na tela, o Post-it é descartado da memória!

### Os 3 Pilares Obrigatórios da Subquery no `FROM` (O Crachá, O Compactador e A Ligação):

```sql
SELECT 
    u.NOME,
    NVL(metas.TOTAL_METAS, 0) AS TOTAL_METAS,
    NVL(records.TOTAL_RECORDES, 0) AS TOTAL_RECORDES
FROM TRE_USUARIO u

-- POST-IT TEMPORÁRIO 1: Metas compactadas por usuário
LEFT JOIN (
    SELECT 
        ID_USUARIO,            -- 1. O CRACHÁ: Obrigatório estar no SELECT interno para podermos ligar lá fora!
        COUNT(*) AS TOTAL_METAS
    FROM TRE_META
    GROUP BY ID_USUARIO        -- 2. O COMPACTADOR: Espreme as 10 metas do aluno em 1 única linha resumida!
) metas ON metas.ID_USUARIO = u.ID_USUARIO  -- 3. A LIGAÇÃO: Conecta o crachá do Post-it com o usuário lá de fora!

-- POST-IT TEMPORÁRIO 2: Recordes compactados por usuário
LEFT JOIN (
    SELECT 
        ID_USUARIO,            -- O crachá de identificação
        COUNT(*) AS TOTAL_RECORDES
    FROM TRE_RECORD
    GROUP BY ID_USUARIO        -- Garante que cada usuário tenha apenas 1 linha aqui dentro
) records ON records.ID_USUARIO = u.ID_USUARIO;
```

* **Por que o `ID_USUARIO` é obrigatório dentro da subquery? (A Analogia do Crachá):**
  Se a subquery selecionasse apenas `SELECT COUNT(*) FROM TRE_META GROUP BY ID_USUARIO`, ela entregaria uma lista de números soltos (`3`, `5`, `2`), mas quem está do lado de fora perguntaria: *"De quem é esse 3? É do Lucas ou da Mariana?"*. Sem selecionar o `ID_USUARIO` dentro do Post-it, o `ON metas.ID_USUARIO = u.ID_USUARIO` lá fora não tem onde se amarrar!
* **Por que isso elimina 100% do Produto Cartesiano?**
  Porque o `GROUP BY ID_USUARIO` dentro do Post-it garante que cada aluno tenha **no máximo 1 linha** naquela tabela temporária. Quando você cruza $1 \text{ linha} \times 1 \text{ linha}$ no `JOIN`, $1 \times 1 = 1$. Nunca multiplica linhas!

### 🛠️ O Método Infalível em 3 Passos para Montar Subqueries Complexas no `FROM`:
Quando a questão pedir para cruzar dados resumidos de Séries, Recordes e Metas por Usuário e Exercício:
1. **Passo 1 (O Rascunho Isolado):** Escreva e teste primeiro só o `SELECT` pequenininho que agrupa as séries por `ID_USUARIO` e `ID_EXERCICIO` trazendo `MAX(s.CARGA)`.
2. **Passo 2 (O Envelope):** Coloque parênteses em volta desse `SELECT` no `FROM` e dê um apelido curto (ex: `res_serie`).
3. **Passo 3 (Os Joins Externos):** Faça `INNER JOIN` com `TRE_USUARIO` e `TRE_EXERCICIO` para buscar os nomes, e `LEFT JOIN` com outros Post-its (ex: resumo de `TRE_RECORD`) ligando sempre pelos **dois crachás ao mesmo tempo**:  
   `ON resumo_r.ID_USUARIO = res_serie.ID_USUARIO AND resumo_r.ID_EXERCICIO = res_serie.ID_EXERCICIO`.

---

## 1.5 Regras de Ouro para Não Errar Subqueries no `FROM`
1. **A Subquery no `FROM` é uma Ilha Fechada:**  
   Diferente da subquery no `SELECT` ou no `WHERE`, uma subquery dentro do `FROM` **NÃO consegue enxergar apelidos de tabelas que estão fora dela**! Se você tentar colocar `WHERE r.ID_USUARIO = u.ID_USUARIO` dentro dos parênteses do `FROM`, o Oracle dá erro de identificador inválido. A ligação com o mundo exterior é feita **exclusivamente na cláusula `ON` do `JOIN`** do lado de fora dos parênteses!
2. **No `GROUP BY` da Subquery só entra quem define o agrupamento:**  
   Se você quer a maior carga por usuário e exercício, o `GROUP BY` interno deve ter **apenas** `ID_USUARIO, ID_EXERCICIO`. Se você colocar `ID_SERIE` ou `ID_TREINO` no `GROUP BY`, cada série ficará em uma caixa separada e o `MAX()` não vai agrupar nada!
3. **NUNCA separe tabelas ou subqueries por vírgula no `FROM`:**  
   Escrever `FROM (SELECT ...) a, (SELECT ...) b` gera um Produto Cartesiano imediato se você esquecer de amarrar todas as chaves no `WHERE`, além de eliminar linhas quando um lado for nulo. Use **sempre** `INNER JOIN ... ON` ou `LEFT JOIN ... ON`.

---

## 1.6 A Tabela `DUAL` (A Analogia da Esteira de Fábrica)

No Oracle, todo comando `SELECT` é **obrigado** por regra gramatical a ter uma cláusula `FROM`.
* Pense no `FROM` como uma **esteira de fábrica**: se você escreve `FROM TRE_USUARIO` e a tabela tem 50 usuários cadastrados, a esteira vai rodar 50 vezes e imprimir 50 linhas na tela.
* E quando você quer exibir em **uma única linha** dois totais completamente independentes (por exemplo: na coluna 1 o total de usuários com a letra 'G' e na coluna 2 o total de exercícios com a letra 'S', já que o professor proibiu `UNION`)?
* Você usa a tabela **`DUAL`**! A `DUAL` é uma tabela nativa do Oracle que possui **exatamente 1 linha e 1 coluna**. Ao fazer `FROM DUAL`, a esteira roda **uma única vez**, executa cada subquery escalar do `SELECT` e mostra o resultado consolidado lado a lado em 1 linha só:

```sql
SELECT 
    (SELECT COUNT(*) FROM TRE_USUARIO WHERE UPPER(NOME) LIKE 'G%') AS QTD_USUARIOS_G,
    (SELECT COUNT(*) FROM TRE_EXERCICIO WHERE UPPER(NOME) LIKE 'S%') AS QTD_EXERCICIOS_S
FROM DUAL;
```

---

## 1.7 Funções Auxiliares de Tratamento (Limpando Nulos e Textos)

| Função | Como Funciona na Prática | Analogia / Quando Usar na Prova | Exemplo Real |
| :--- | :--- | :--- | :--- |
| **`NVL(valor, substituto)`** | Exclusiva do Oracle. Recebe 2 argumentos: se o 1º for `NULL`, devolve o 2º. | **O Tapa-Buraco:** Quando você faz `LEFT JOIN` e o aluno não tem meta, a coluna vem `NULL`. O `NVL` troca o vazio por `0`. | `NVL(m.CARGA_ALVO, 0)` |
| **`COALESCE(v1, v2, v3...)`** | Padrão SQL universal. Olha a lista da esquerda para a direita e devolve o **primeiro valor não-nulo** que encontrar. | **O Plano de Contingência (Plano A, B, C):** Tenta usar a carga da meta; se for nula, tenta usar o recorde; se ambos forem nulos, mostra `0`. | `COALESCE(m.CARGA_ALVO, r.CARGA_RECORD, 0)` |
| **`UPPER(texto)`** | Converte todas as letras do texto para MAIÚSCULAS. | **O Padronizador:** Garante que buscas com `LIKE` encontrem `'gabriel'`, `'Gabriel'` ou `'GABRIEL'`. | `WHERE UPPER(u.NOME) LIKE 'G%'` |

---

## 1.8 🔥 GUIA MESTRE DAS SUBQUERIES: O Que Muda no `SELECT`, no `FROM`/`JOIN`, no `WHERE` e no `HAVING`?

Se você sente que às vezes confunde o que pode ou não pode fazer dentro de uma subquery, **o segredo está na POSIÇÃO onde você abriu o parêntese `(SELECT ...)`**!
No SQL, uma subquery muda completamente de comportamento dependendo do lugar onde ela mora.

---

### 🗺️ 1. O Mapa Visual das 4 Posições de Subquery

```
SELECT 
    u.NOME,
    (SELECT ...) AS COLUNA_CALCULADA          ◄── [POSIÇÃO 1: NO SELECT]
                                                  • É uma CÉLULA DO EXCEL (1 linha x 1 coluna).
                                                  • ENXERGA a tabela de fora (usa WHERE r.ID = u.ID lá dentro).
                                                  • NÃO usa GROUP BY lá dentro!

FROM TRE_USUARIO u
LEFT JOIN (
    SELECT ID_USUARIO, MAX(CARGA) ...         ◄── [POSIÇÃO 2: NO FROM ou JOIN]
    FROM ...                                      • É uma TABELA TEMPORÁRIA INTEIRA (várias linhas e colunas).
    GROUP BY ID_USUARIO                           • NÃO ENXERGA a tabela de fora (Ilha Fechada!).
) resumo ON resumo.ID_USUARIO = u.ID_USUARIO      • Usa GROUP BY + Crachá (ID) lá dentro, e liga no ON lá fora!

WHERE u.ID_USUARIO IN (SELECT ...)            ◄── [POSIÇÃO 3: NO WHERE]
   OR r.CARGA = (SELECT MAX(...) FROM ...)        • É um FILTRO DE LINHAS (não cria coluna na tela!).
                                                  • Com '=' devolve 1 valor só; com 'IN / NOT IN' devolve 1 coluna com várias linhas.

GROUP BY ...
HAVING AVG(s.CARGA) = (SELECT MAX(AVG(...))   ◄── [POSIÇÃO 4: NO HAVING]
                       FROM ...                   • É um FILTRO DE CAIXAS JÁ AGRUPADAS (ex: achar a maior média).
                       GROUP BY ID_USUARIO)       • Tem GROUP BY lá dentro, mas NÃO tem ID no SELECT de dentro!
```

---

### 📊 2. Tabela Comparativa Direta (Bateu o Olho, Lembrou na Prova!)

| Pergunta / Regra | 1️⃣ Subquery no `SELECT` | 2️⃣ Subquery no `FROM` ou `JOIN` | 3️⃣ Subquery no `WHERE` | 4️⃣ Subquery no `HAVING` |
| :--- | :--- | :--- | :--- | :--- |
| **O que ela é na prática?** | Uma **célula única** (uma coluna calculada na tela). | Uma **tabela temporária (Post-it)** com várias linhas e colunas. | Um **porteiro (filtro)** que decide qual linha passa ou é barrada. | Um **juiz final** que compara o resultado de um grupo com o teto geral. |
| **Quantas COLUNAS pode ter no `SELECT` dela?** | **Apenas 1 coluna!** (Se colocar 2 colunas, dá erro `ORA-00913`). | **Quantas colunas você quiser!** (Geralmente os IDs de crachá + os cálculos). | **Apenas 1 coluna!** | **Apenas 1 coluna!** |
| **Quantas LINHAS ela pode devolver?** | **Apenas 1 linha!** (Por isso sempre usamos `COUNT`, `MAX`, `MIN`, `SUM` lá dentro). | **Várias linhas!** (Uma linha para cada usuário/exercício agrupado). | • Com `=`, `>`, `<`: **1 linha**.<br>• Com `IN` / `NOT IN`: **Várias linhas**. | Com `=`: **1 linha** (ex: `MAX(AVG(...))`). |
| **Ela enxerga a tabela de fora (`u.ID_USUARIO`)?** | ✅ **SIM!** Você escreve `WHERE r.ID_USUARIO = u.ID_USUARIO` **dentro** dela! | ❌ **NUNCA!** É uma **Ilha Fechada**! Se tentar usar `u.ID_USUARIO` lá dentro, dá erro `ORA-00904`! | ✅ **SIM!** Pode ser independente (maior do banco) ou amarrada à linha de fora (ex: no `UPDATE`). | Geralmente **NÃO** precisa (ela olha a tabela toda para achar o `MAX(AVG)`). |
| **Precisa de `GROUP BY` lá dentro?** | ❌ **NÃO!** (Como o `WHERE` interno já filtra 1 aluno por vez, não precisa agrupar). | ✅ **SIM!** (Para espremer várias linhas em 1 linha por `ID_USUARIO` e evitar produto cartesiano). | ❌ **NÃO!** (Usa apenas `MAX(...)`, `MIN(...)` ou lista de `ID`s). | ✅ **SIM!** (Usa `GROUP BY ID_USUARIO` lá dentro para o `MAX(AVG(...))` funcionar). |
| **Como se conecta com a consulta de fora?** | Pelo **`WHERE` dentro** dos parênteses + `AS APELIDO` fora. | Pelo **`ON` fora** dos parênteses (`ON res.ID = u.ID`). | Pelo operador **antes** do parêntese (`WHERE col = (...)` ou `WHERE col IN (...)`). | Pelo operador **antes** do parêntese (`HAVING AVG(...) = (...)`). |

---

### ⚔️ 3. O Confronto Lado a Lado: O MESMO Problema no `SELECT` vs no `FROM` (`LEFT JOIN`)

Muitas vezes na prova você pode escolher se quer resolver pelo `SELECT` ou pelo `FROM`/`JOIN`. Veja exatamente **o que muda de lugar** quando resolvemos o mesmo problema das duas formas:

> **Objetivo:** Mostrar o nome de todos os usuários e o maior recorde (`MAX(CARGA_RECORD)`) de cada um (mostrando `0` para quem não tem).

#### 🅰️ Fazendo com Subquery no `SELECT` (A Célula do Excel):
```sql
SELECT
    u.NOME,
    NVL((
        SELECT MAX(r.CARGA_RECORD)      -- 1. Só 1 coluna no SELECT interno (NÃO coloca ID_USUARIO aqui!)
        FROM TRE_RECORD r
        WHERE r.ID_USUARIO = u.ID_USUARIO -- 2. Enxerga o 'u' de fora! Faz a ligação AQUI DENTRO no WHERE!
                                        -- 3. NÃO tem GROUP BY aqui dentro!
    ), 0) AS MAIOR_RECORD
FROM TRE_USUARIO u;                     -- 4. O FROM lá fora fica limpinho, sem nenhum JOIN!
```

#### 🅱️ Fazendo com Subquery no `FROM` / `LEFT JOIN` (O Post-it / Ilha Fechada):
```sql
SELECT
    u.NOME,
    NVL(res.MAIOR_RECORD, 0) AS MAIOR_RECORD -- 1. Puxa a coluna pronta lá do Post-it 'res'
FROM TRE_USUARIO u
LEFT JOIN (
    SELECT 
        r.ID_USUARIO,                   -- 2. OBRIGATÓRIO colocar o Crachá (ID_USUARIO) no SELECT interno!
        MAX(r.CARGA_RECORD) AS MAIOR_RECORD
    FROM TRE_RECORD r
    -- ❌ PROIBIDO colocar 'WHERE r.ID_USUARIO = u.ID_USUARIO' aqui dentro! (Ilha fechada!)
    GROUP BY r.ID_USUARIO               -- 3. OBRIGATÓRIO usar GROUP BY aqui dentro para separar por aluno!
) res ON res.ID_USUARIO = u.ID_USUARIO; -- 4. A ligação com o 'u' é feita AQUI FORA no ON!
```

> 💡 **Olhe para os dois códigos acima e grave esta regra de ouro:**
> * **Vai fazer no `SELECT`?** $\rightarrow$ **SEM** `ID` no `SELECT` interno, **SEM** `GROUP BY` interno, e **COM** `WHERE r.ID = u.ID` **dentro**!
> * **Vai fazer no `FROM` / `JOIN`?** $\rightarrow$ **COM** `ID` no `SELECT` interno, **COM** `GROUP BY ID` interno, e **COM** `ON res.ID = u.ID` **fora**!
> * *(Se o enunciado da prova NÃO obrigar a usar subquery no `FROM`, a versão no `SELECT` é mais rápida de escrever e tem zero risco de duplicar linhas!).*

---

### 🧩 4. Os 3 Padrões de Subquery no `FROM` que Aparecem na Prova

Quando você **precisar** usar Subquery no `FROM` (ou porque o enunciado exigiu, ou porque você está numa Procedure como na `ATV_GRUPO.sql`, ou porque precisa trazer várias colunas resumidas de uma vez), ela sempre seguirá um destes **3 desenhos**:

#### Desenho 1: `FROM TABELA_MAE LEFT JOIN (Subquery)`
* **Quando usar:** Você quer listar **todos** os usuários (ou todas as metas/exercícios) e colar ao lado um resumo que veio de uma tabela filha (`TRE_SERIE` ou `TRE_RECORD`).
* **Cuidado único:** Sempre usar `LEFT JOIN` (para não sumir com quem tem zero) e colocar `NVL(res.COLUNA, 0)` lá no `SELECT` de fora!

#### Desenho 2: `FROM (Subquery)` Sozinha (Padrão das Procedures do `ATV_GRUPO.sql`!)
* **Quando usar:** Quando você quer calcular o **maior de uma contagem** (`MAX(COUNT)`) ou o **maior retorno de uma Function** dentro de uma Procedure!
* **Por que não precisa de `ON` nesse caso?** Porque só existe a subquery no `FROM` (você não está juntando ela com outra tabela):
  ```sql
  SELECT MAX(res.QTD_SERIE)
  INTO v_maior
  FROM (
      -- Post-it que conta as séries de cada treino:
      SELECT ID_TREINO, COUNT(ID_SERIE) AS QTD_SERIE
      FROM ...
      GROUP BY ID_TREINO
  ) res;
  ```

#### Desenho 3: `FROM (Subquery 1) INNER JOIN (Subquery 2) INNER JOIN (Subquery 3)` (Maior e Menor por Categoria)
* **Quando usar:** Quando a questão pede na mesma linha o **Grupo Muscular**, o **Nome do Exercício Maior + Maior Carga** e o **Nome do Exercício Menor + Menor Carga**.
* **Cuidado único:** Nos dois `ON` lá de fora, você **SEMPRE** precisa comparar **2 coisas** com `AND`:
  1. O valor da carga (`ON maior.CARGA = resumo.MAIOR_CARGA`)
  2. **E** o crachá do grupo (`AND maior.ID_GRP_MUSCULAR = resumo.ID_GRP_MUSCULAR`)!

---

### 🧭 5. Bússola de 5 Segundos para a Prova ("Qual Subquery eu uso em cada questão?")

Amanhã na prova, quando ler o enunciado, faça estas perguntas:

1. **A questão quer mostrar uma listagem com contagens (`TOTAL_TREINOS`, `TOTAL_METAS`, `MAIOR_CARGA`) ao lado do nome do usuário/exercício/meta?**
   * 👉 Se não exigir subquery no `FROM`, use **Subquery no `SELECT`**! É uma célula do Excel por coluna, ligada com `WHERE filha.ID = mae.ID`.
   * 👉 Se exigir subquery no `FROM`, use **`LEFT JOIN (SELECT ID, MAX(...) FROM ... GROUP BY ID) res ON res.ID = mae.ID`**.

2. **A questão quer mostrar apenas O CAMPEÃO ABSOLUTO (ex: *"Qual o nome do usuário e o código do treino que teve a maior duração do banco?"*)?**
   * 👉 Use **Subquery no `WHERE` com `=`**:
     `WHERE t.DURACAO_MINUTO = (SELECT MAX(DURACAO_MINUTO) FROM TRE_TREINO)`
     *(E lembre-se: sem `GROUP BY` na consulta principal!).*

3. **A questão quer mostrar O CAMPEÃO DE UMA MÉDIA OU CONTAGEM (ex: *"Qual usuário tem a maior média geral de carga?"*)?**
   * 👉 Use **`GROUP BY` na consulta principal + Subquery no `HAVING`**:
     `GROUP BY u.ID_USUARIO, u.NOME HAVING AVG(s.CARGA) = (SELECT MAX(AVG(s2.CARGA)) FROM ... GROUP BY t2.ID_USUARIO)`
     *(Lembrete: dentro da subquery do `HAVING`, nunca coloque `ID_USUARIO` no `SELECT`, coloque só o `MAX(AVG(...))`!).*

4. **A questão pede um `DELETE` (apagar quem nunca teve treino/item) ou um `UPDATE` filtrando quem está/não está em outra tabela?**
   * 👉 Use **Subquery no `WHERE` com `IN` ou `NOT IN`**:
     `WHERE ID_TREINO NOT IN (SELECT ID_TREINO FROM TRE_ITEM_TREINO WHERE ID_TREINO IS NOT NULL)`
     *(Com `NOT IN`, nunca esqueça o `WHERE ID IS NOT NULL` lá dentro!).*

5. **A questão pede dois totais de tabelas diferentes que não têm nada a ver uma com a outra em uma linha só (ex: *"Quantos usuários com G e quantos exercícios com S"*)?**
   * 👉 Use **Duas Subqueries no `SELECT` consultando `FROM DUAL`**!

---
---

# PARTE 2: GROUP BY, HAVING, EXTREMOS, FUNÇÕES NUMÉRICAS E VIEWS (DIA 2)

## 2.1 A Regra de Ouro do `GROUP BY` (A Analogia das Caixas de Papelão Lacradas)

Imagine que você tem 500 fichas de séries espalhadas pelo chão da academia.
Quando você escreve `GROUP BY u.ID_USUARIO, u.NOME`, você está pegando uma caixa de papelão para cada aluno, escrevendo o `ID_USUARIO` e o `NOME` com canetão preto **na etiqueta do lado de fora da caixa**, jogando todas as fichas daquele aluno lá dentro e **lacrando a caixa com fita adesiva**.

> 🚨 **A LEI INQUEBRÁVEL DO `GROUP BY` (Erro `ORA-00979`):**  
> Depois que a caixa está lacrada, do lado de fora você só consegue enxergar duas coisas:
> 1. **O que está escrito na etiqueta externa da caixa** (as colunas listadas no `GROUP BY`).
> 2. **Medições consolidadas da caixa inteira** (funções agregadoras: `COUNT` para contar quantas fichas tem lá dentro, `SUM` para somar tudo, `AVG` para a média, `MAX` para o maior valor, `MIN` para o menor valor).

Se você tentar colocar no `SELECT` uma coluna individual que ficou trancada lá dentro (como `t.DATA_TREINO` ou `s.NUMERO_SERIE`) sem colocá-la no `GROUP BY` e sem função agregadora, o Oracle trava imediatamente com o erro:  
**`ORA-00979: not a GROUP BY expression` (não é uma expressão GROUP BY)**.  
*Por quê?* Porque dentro da caixa do aluno existem 30 datas de treino diferentes, e o Oracle não tem como adivinhar qual das 30 datas você quer exibir em uma linha única!

---

## 2.2 `WHERE` vs `HAVING` (A Peneira Grossa vs O Controle de Qualidade)

Ambos servem para filtrar, mas agem em momentos cronológicos opostos dentro do motor do banco de dados:

```
   [1. Tabelas Cruas com Linhas Soltas]
                 │
                 ▼
   [2. WHERE] ──► (A Peneira Grossa: Filtra fichas individuais ANTES de entrarem na caixa)
                 │  ❌ PROIBIDO usar funções de grupo aqui (AVG, COUNT, MAX)!
                 ▼
   [3. GROUP BY] ► (O Empacotador: Fecha as caixas e calcula as etiquetas de soma, média e contagem)
                 │
                 ▼
   [4. HAVING] ─► (O Controle de Qualidade: Olha para as caixas JÁ FECHADAS e descarta caixas inteiras)
                    ✅ AQUI entram os filtros com funções de grupo: HAVING COUNT(*) > 1, HAVING AVG(CARGA) >= 80
```

* **Erro Clássico de Prova (`ORA-00934`):** Escrever `WHERE AVG(s.CARGA) > 80` ou `WHERE COUNT(t.ID_TREINO) > 1`. No instante em que o `WHERE` está rodando, as caixas ainda nem foram montadas e a média ainda não existe! Filtros sobre `COUNT`, `AVG`, `SUM`, `MAX` e `MIN` moram **obrigatoriamente no `HAVING`**.

### 💻 Exemplo Completo Comentado (`WHERE` + `GROUP BY` + `HAVING` juntos):
```sql
SELECT
    u.ID_USUARIO,                         -- Está na etiqueta da caixa (GROUP BY)
    u.NOME AS NOME_USUARIO,               -- Está na etiqueta da caixa (GROUP BY)
    COUNT(t.ID_TREINO) AS QTD_TREINOS,    -- Medição da caixa fechada (contagem)
    ROUND(AVG(t.DURACAO_MINUTO), 2) AS MEDIA_TEMPO, -- Medição da caixa (média arredondada)
    MAX(t.DURACAO_MINUTO) AS MAIOR_TREINO -- Medição da caixa (maior valor)
FROM TRE_USUARIO u
INNER JOIN TRE_TREINO t ON t.ID_USUARIO = u.ID_USUARIO
-- 1. PENEIRA GROSSA (WHERE): Filtra linha por linha ANTES de entrar na caixa
-- Exemplo: considerar apenas treinos que duraram pelo menos 20 minutos
WHERE t.DURACAO_MINUTO >= 20
-- 2. EMPACOTADOR (GROUP BY): Cria uma caixa lacrada para cada usuário
GROUP BY u.ID_USUARIO, u.NOME
-- 3. CONTROLE DE QUALIDADE (HAVING): Olha para a caixa JÁ LACRADA e só deixa passar
-- os usuários que acumularam mais de 1 treino dentro da caixa!
HAVING COUNT(t.ID_TREINO) > 1;
```

---

## 2.3 Como Pescar o "Dono" do Maior ou Menor Valor (`MAX` e `MIN` com Subqueries)

Se a prova perguntar apenas *"Qual é o maior recorde do banco?"*, basta `SELECT MAX(CARGA_RECORD) FROM TRE_RECORD;`.
Mas na prova real, o professor sempre pergunta: **"Qual o NOME do usuário e o NOME do exercício que possuem o maior recorde?"**

Se você tentar fazer `SELECT u.NOME, e.NOME, MAX(r.CARGA_RECORD) ... GROUP BY u.NOME, e.NOME`, o banco **não vai trazer apenas o campeão geral** — ele vai trazer o maior recorde de cada aluno em cada exercício (dezenas de linhas)!

### A Solução Padrão de Prova: Subquery Aninhada no `WHERE`!
Você usa uma subquery dentro do `WHERE` como um **Filtro de Elite** que descobre primeiro qual é o número campeão absoluto, e a consulta principal apenas exibe quem tem carga igual àquele número:

```sql
SELECT 
    u.NOME AS USUARIO,
    e.NOME AS EXERCICIO,
    r.CARGA_RECORD
FROM TRE_RECORD r
INNER JOIN TRE_USUARIO u ON u.ID_USUARIO = r.ID_USUARIO
INNER JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = r.ID_EXERCICIO
WHERE r.CARGA_RECORD = (
    -- Subquery que descobre o maior valor absoluto do banco (ex: 320.00):
    SELECT MAX(CARGA_RECORD) 
    FROM TRE_RECORD
);
```
> **Mudança de Mindset Importante:** Repare que no `SELECT` externo colocamos apenas `r.CARGA_RECORD` (sem `MAX` e sem `GROUP BY`). Por quê? Porque o `WHERE` já jogou no lixo todas as outras linhas do banco e deixou passar **somente a linha campeã**! Você só precisa ler os dados dela.

### E quando a prova pede o Maior E o Menor de cada Categoria (Grupo Muscular) ao mesmo tempo?
Quando você precisa mostrar na mesma linha o **Grupo Muscular**, o **Maior Recorde + Nome do Exercício** e o **Menor Recorde + Nome do Exercício** (sem poder usar `WITH` nem `UNION`):
1. Você cria uma **Subquery no `FROM`** (`max_min_grp_rec`) que agrupa por `ID_GRP_MUSCULAR` e calcula `MAX(CARGA_RECORD)` e `MIN(CARGA_RECORD)`.
2. Você faz `INNER JOIN` com uma subquery (`ex_maior_rec`) para descobrir o exercício dono do `MAX` (amarrando pelo `ID_GRP_MUSCULAR` e pela carga igual ao `maior_record`).
3. Você faz outro `INNER JOIN` com uma subquery (`ex_menor_rec`) para descobrir o exercício dono do `MIN` (amarrando pelo `ID_GRP_MUSCULAR` e pela carga igual ao `menor_record`).

#### 💻 Exemplo Completo Comentado (Maior e Menor Recorde por Grupo Muscular + Seus Donos):
```sql
SELECT
    max_min_grp_rec.NOME AS GRUPO_MUSCULAR,
    ex_maior_rec.EXERCICIO AS EXERCICIO_MAIOR_RECORDE,
    max_min_grp_rec.MAIOR_RECORD,
    ex_menor_rec.EXERCICIO AS EXERCICIO_MENOR_RECORDE,
    max_min_grp_rec.MENOR_RECORD
FROM (
    -- 1. POST-IT CENTRAL: Descobre o valor numérico do MAIOR e do MENOR recorde de cada grupo muscular
    SELECT
        grp.NOME,
        e.ID_GRP_MUSCULAR,                 -- Crachá obrigatório para ligar lá fora!
        MAX(r.CARGA_RECORD) AS MAIOR_RECORD,
        MIN(r.CARGA_RECORD) AS MENOR_RECORD
    FROM TRE_RECORD r
    INNER JOIN TRE_EXERCICIO e ON r.ID_EXERCICIO = e.ID_EXERCICIO
    INNER JOIN TRE_GRUPOMUSCULAR grp ON grp.ID_GRP_MUSCULAR = e.ID_GRP_MUSCULAR
    GROUP BY grp.NOME, e.ID_GRP_MUSCULAR
) max_min_grp_rec

-- 2. POST-IT DO CAMPEÃO (MAIOR): Busca o nome do exercício que bateu exatamente o MAIOR_RECORD daquele grupo
INNER JOIN (
    SELECT
        e.NOME AS EXERCICIO, 
        e.ID_GRP_MUSCULAR,                 -- Crachá do grupo
        r.CARGA_RECORD AS MAIOR_REC        -- Valor da carga para comparar com o MAX
    FROM TRE_EXERCICIO e
    INNER JOIN TRE_RECORD r ON r.ID_EXERCICIO = e.ID_EXERCICIO
) ex_maior_rec 
    ON ex_maior_rec.MAIOR_REC = max_min_grp_rec.MAIOR_RECORD
   AND ex_maior_rec.ID_GRP_MUSCULAR = max_min_grp_rec.ID_GRP_MUSCULAR

-- 3. POST-IT DO LANTERNA (MENOR): Busca o nome do exercício que teve exatamente o MENOR_RECORD daquele grupo
INNER JOIN (
    SELECT
        e.NOME AS EXERCICIO,
        e.ID_GRP_MUSCULAR,                 -- Crachá do grupo
        r.CARGA_RECORD AS MENOR_REC        -- Valor da carga para comparar com o MIN
    FROM TRE_EXERCICIO e
    INNER JOIN TRE_RECORD r ON r.ID_EXERCICIO = e.ID_EXERCICIO
) ex_menor_rec 
    ON ex_menor_rec.MENOR_REC = max_min_grp_rec.MENOR_RECORD
   AND ex_menor_rec.ID_GRP_MUSCULAR = max_min_grp_rec.ID_GRP_MUSCULAR;
```

---

## 2.4 Por que não posso usar `MAX(AVG)` direto sem Subquery no `HAVING`?

Quando a questão pede: *"Mostre o nome do usuário que possui a MAIOR MÉDIA GERAL de cargas do sistema"*, por que temos que escrever uma subquery dentro do `HAVING`?

* **A Analogia das Mesas na Sala de Aula:**
  Imagine que o `GROUP BY u.NOME` dividiu os alunos em mesas separadas.
  Quando o Oracle está avaliando a mesa do Lucas no `HAVING`, ele calcula a média do Lucas (`AVG(s.CARGA) = 94.00 kg`).
  Para saber se $94.00\text{ kg}$ é a **maior média da sala inteira**, o `HAVING` precisa comparar esse número com o teto máximo de todas as mesas. Mas ele está olhando apenas para a mesa do Lucas!
* **O Papel da Subquery no `HAVING`:**
  O Oracle permite aninhar duas funções de grupo (`MAX(AVG(...))`) **apenas quando há um `GROUP BY` sem outras colunas soltas no `SELECT`**. Então criamos uma subquery assistente que percorre todas as mesas (`GROUP BY ID_USUARIO`), calcula a média de cada uma e extrai a maior de todas (`MAX(AVG(CARGA))`):

```sql
SELECT 
    u.NOME,
    ROUND(AVG(s.CARGA), 2) AS MEDIA_CARGA
FROM TRE_USUARIO u
INNER JOIN TRE_TREINO t ON t.ID_USUARIO = u.ID_USUARIO
INNER JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
INNER JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
GROUP BY u.ID_USUARIO, u.NOME
HAVING AVG(s.CARGA) = (
    -- O Assistente: calcula a média de cada usuário e devolve apenas a MAIOR média de todas!
    SELECT MAX(AVG(s2.CARGA))
    FROM TRE_TREINO t2
    INNER JOIN TRE_ITEM_TREINO it2 ON it2.ID_TREINO = t2.ID_TREINO
    INNER JOIN TRE_SERIE s2 ON s2.ID_ITEM_TREINO = it2.ID_ITEM_TREINO
    GROUP BY t2.ID_USUARIO
);
```

---

## 2.5 Funções Auxiliares Numéricas e de Data (`ROUND`, `TRUNC`, `NULLIF`)

| Função | O que faz exatamente | Analogia e Aplicação Prática | Exemplo Real |
| :--- | :--- | :--- | :--- |
| **`ROUND(num, casas)`** | Arredonda matematicamente o número para a quantidade de casas decimais informada. Se omitir as casas, arredonda para inteiro. | **O Cosmético das Médias:** Uma divisão ou `AVG()` gera dízimas como `73.3333333`. O `ROUND(..., 2)` entrega `73.33` limpo. | `ROUND(AVG(s.CARGA), 2)` |
| **`TRUNC(num, casas)`** | Corta (trunca) as casas decimais a seco, sem arredondar para cima. | **A Tesoura Cega:** Se o número for `73.389`, `TRUNC(73.389, 2)` devolve `73.38`. | `TRUNC(AVG(s.CARGA), 2)` |
| **`TRUNC(data)`** | Remove as horas, minutos e segundos de uma data (zera o relógio para `00:00:00`). | **O Carimbo de Dia Puro:** No Oracle, `SYSDATE` guarda data e hora exata (`16/10/2026 20:45:12`). Para gravar ou comparar apenas o dia, usa-se `TRUNC(SYSDATE)`. | `DATA_RECORD = TRUNC(SYSDATE)` |
| **`NULLIF(exp1, exp2)`** | Compara os dois valores: se forem **iguais**, retorna `NULL`. Se forem diferentes, retorna o `exp1`. | **O Extintor contra Divisão por Zero (`ORA-01476`):** Ao fazer `SOMA / NULLIF(QTD, 0)`, se `QTD` for `0`, o `NULLIF` transforma o `0` em `NULL`. No SQL, qualquer número dividido por `NULL` dá `NULL` em vez de travar o banco com erro! | `SUM(s.REPETICOES) / NULLIF(COUNT(s.ID_SERIE), 0)` |

---

## 2.6 `VIEWS` Analíticas: Do "Post-it" ao "Caderno de Receitas Definitivo"

Se uma Subquery no `FROM` é um Post-it que vai para o lixo assim que a consulta termina, uma **`VIEW`** é uma consulta que você **batiza com um nome e salva permanentemente no dicionário do banco de dados**.

* **A Analogia do Caderno de Receitas:**  
  A View **NÃO duplica os dados físicos da tabela** e não ocupa espaço extra com linhas copiadas. Ela guarda apenas a **fórmula (`SELECT`)**. Toda vez que alguém faz um `SELECT * FROM nome_da_view`, o Oracle abre o caderno, roda a receita por baixo dos panos buscando os dados atualizados em tempo real nas tabelas originais e entrega o resultado pronto!

### Sintaxe Completa de Criação e Consumo:
```sql
-- 1. CRIANDO OU ATUALIZANDO A VIEW:
CREATE OR REPLACE VIEW VW_RESUMO_EXERCICIOS AS
SELECT 
    e.ID_EXERCICIO,
    e.NOME AS EXERCICIO,
    COUNT(s.ID_SERIE) AS QTD_SERIES_REALIZADAS,
    NVL(MAX(s.CARGA), 0) AS MAIOR_CARGA,
    ROUND(NVL(AVG(s.CARGA), 0), 2) AS MEDIA_CARGA
FROM TRE_EXERCICIO e
LEFT JOIN TRE_ITEM_TREINO it ON it.ID_EXERCICIO = e.ID_EXERCICIO
LEFT JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
GROUP BY e.ID_EXERCICIO, e.NOME;

-- 2. CONSUMINDO A VIEW (Exatamente como se fosse uma tabela física!):
SELECT * 
FROM VW_RESUMO_EXERCICIOS
WHERE MAIOR_CARGA >= 100;
```

> ⚠️ **Regra de Ouro nas Views:** Dentro de uma View, toda coluna calculada (`COUNT(...)`, `ROUND(...)`, `MAX(...)`) **DEVE ter um apelido (`AS nome_coluna`)**! O Oracle exige nomes válidos para criar as colunas virtuais da View.

---
---

# PARTE 3: PROCEDURES, PARÂMETROS (IN, OUT, IN OUT), DML ANINHADO E OPERADORES (DIA 3)

## 3.1 O que é uma `PROCEDURE` e a Regra do `SELECT ... INTO`

* **A Analogia do Robô de Fábrica:**  
  Um comando `SELECT` solto é passivo: apenas lê e mostra dados na tela.  
  Uma **`PROCEDURE`** é um **robô programado** que fica armazenado dentro do servidor Oracle. Você aperta um botão (`EXEC` ou bloco `BEGIN ... END`), passa matérias-primas (parâmetros), e o robô valida condições (`IF / ELSIF / ELSE`), executa comandos pesados de alteração (`INSERT`, `UPDATE`, `DELETE`), lê dados para a memória e imprime relatórios.

### Estrutura Base de uma Procedure:
```sql
CREATE OR REPLACE PROCEDURE PRC_NOME_DA_ROTINA (
    p_parametro1 IN NUMBER,
    p_parametro2 OUT VARCHAR2
)
IS -- (Pode usar IS ou AS, são sinônimos perfeitos!)
    -- Área de declaração de variáveis locais de memória (sem a palavra DECLARE!)
    v_variavel_apoio NUMBER := 0;
BEGIN
    -- Corpo executável: SELECT INTO, IF/ELSE, INSERT, UPDATE, DELETE, DBMS_OUTPUT
END;
/
```

### A Regra Obrigatória do `SELECT ... INTO` dentro do PL/SQL:
No SQL puro, você roda `SELECT NOME FROM TRE_USUARIO WHERE ID_USUARIO = 1;` e o resultado aparece na grade da tela.  
Dentro de um bloco PL/SQL (Procedure ou Function), **você NUNCA pode deixar um `SELECT` solto sem `INTO`**! O motor do PL/SQL trabalha na memória RAM: toda consulta precisa despejar seus valores dentro de variáveis ("baldes"):

```sql
SELECT id_usuario, nome
INTO v_id_usuario, v_nome_usr -- Cada coluna do SELECT cai na variável correspondente na mesma ordem!
FROM tre_usuario
WHERE cod_usuario = p_cod_usuario;
```

> 🪑 **A Armadilha Mortal do `SELECT ... INTO` (A Cadeira de Um Único Lugar - Erro `ORA-01422`):**  
> Uma variável escalar no `SELECT ... INTO` é uma **cadeira de um único assento**. Ela só suporta receber **exatamente 1 linha**.
> * Se a consulta devolver **0 linhas** (não encontrou ninguém), o Oracle dispara o erro `ORA-01403: no data found`.
> * Se a consulta devolver **2 ou mais linhas** (por exemplo, você buscou o código do treino com maior duração `WHERE duracao_minuto = v_maior_duracao`, mas o aluno empatou em dois treinos de 60 minutos), duas linhas tentam sentar na mesma cadeira e o Oracle quebra com o erro:  
>   **`ORA-01422: exact fetch returns more than requested number of rows`**.
> * **Como blindar contra empates na prova?**
>   1. Use uma função agregadora como **`MAX(t.cod_treino)`** (funções de grupo sem `GROUP BY` garantem matematicamente o retorno de 1 única linha!).
>   2. Ou adicione **`AND ROWNUM = 1`** no final do `WHERE` para cortar na primeira linha encontrada.

---

## 3.2 Desmistificando os Parâmetros: `IN`, `OUT` e `IN OUT` (A Analogia dos Envelopes)

```
           ┌────────────────────────────┐
  p_in ───►│  PROCEDURE (Apenas Lê)     │
           └────────────────────────────┘

           ┌────────────────────────────┐
           │  PROCEDURE (Apenas Escreve)│───► p_out
           └────────────────────────────┘

           ┌────────────────────────────┐
p_in_out ─►│  PROCEDURE (Lê e Modifica) │───► p_in_out (valor atualizado!)
           └────────────────────────────┘
```

### 1. ✉️ Parâmetro `IN` (A Carta Selada — Entrada / Somente Leitura)
* **A Analogia:** Você entrega uma carta lacrada para a procedure. O robô lê o dado lá dentro (ex: `p_id_usuario`), usa em filtros `WHERE`, mas é **estritamente proibido de rabiscar ou alterar o valor dessa carta**.
* **Regras:** É o modo padrão (se você omitir a palavra `IN`, o Oracle assume `IN`). Se você tentar fazer `p_id_usuario := 5;` dentro da procedure, o código nem compila!

### 2. 📭 Parâmetro `OUT` (O Envelope Vazio — Saída / Retorno de Valor)
* **A Analogia:** Você entrega um envelope em branco para a procedure. Lá dentro, a procedure faz cálculos ou buscas, escreve o resultado dentro desse envelope (`p_status := 'META BATIDA';`) e te devolve no final.
* **Regras:** Entra vazio (`NULL`). Serve para uma procedure devolver **1, 2, 5 ou quantos valores você quiser** para quem a chamou!

### 3. 🔄 Parâmetro `IN OUT` (A Ficha de Academia que Entra, é Carimbada e Devolvida)
* **A Analogia:** Você entrega uma ficha já preenchida com uma proposta de carga (ex: `p_carga = -5 kg`). A procedure lê esse valor, vê que carga negativa é inválida, risca o `-5`, escreve `1 kg` no mesmo lugar (`p_carga := 1;`), usa no `INSERT` e te devolve a ficha corrigida!
* **Regras:** Entra com valor, permite leitura (`IF p_carga <= 0`) e permite reatribuição (`p_carga := 1;`), alterando a variável original de quem chamou.

| Modo | Entra com valor de fora? | A Procedure pode alterar (`:=`)? | Devolve valor para fora? | Pode passar número/texto fixo na chamada? |
| :---: | :---: | :---: | :---: | :---: |
| **`IN`** | ✅ Sim | ❌ **NÃO** (Somente leitura) | ❌ Não | ✅ Sim (`10`, `'USR-001'`, ou variável) |
| **`OUT`** | ❌ Não (Entra `NULL`) | ✅ **SIM** (Escrita) | ✅ Sim | ❌ **NUNCA!** Exige variável declarada! |
| **`IN OUT`** | ✅ Sim | ✅ **SIM** (Lê e sobrescreve) | ✅ Sim | ❌ **NUNCA!** Exige variável declarada! |

---

## 3.3 Exemplo Real Completo de `PROCEDURE` + Bloco Anônimo de Teste

```sql
-- 1. CRIAÇÃO DA PROCEDURE COM OS 3 TIPOS DE PARÂMETROS:
CREATE OR REPLACE PROCEDURE PRC_VALIDAR_PROGRESSAO (
    p_id_usuario     IN TRE_USUARIO.ID_USUARIO%TYPE,     -- Apenas lê o ID do aluno
    p_id_exercicio   IN TRE_EXERCICIO.ID_EXERCICIO%TYPE, -- Apenas lê o ID do exercício
    p_carga_proposta IN OUT NUMBER,                      -- Entra com peso, corrige se < 5 e devolve
    p_mensagem_meta  OUT VARCHAR2                        -- Sai com o veredito final
)
IS
    v_carga_alvo TRE_META.CARGA_ALVO%TYPE;
BEGIN
    -- Regra 1: Saneamento do parâmetro IN OUT
    IF p_carga_proposta < 5 THEN
        p_carga_proposta := 5;
    END IF;

    -- Regra 2: Busca a meta ativa no banco
    SELECT CARGA_ALVO
    INTO v_carga_alvo
    FROM TRE_META
    WHERE ID_USUARIO = p_id_usuario
      AND ID_EXERCICIO = p_id_exercicio
      AND STATUS = 'ATIVA';

    -- Regra 3: Avalia e preenche o envelope de saída (OUT)
    IF p_carga_proposta = v_carga_alvo THEN
        p_mensagem_meta := 'Meta batida exatamente!';
    ELSIF p_carga_proposta > v_carga_alvo THEN
        p_mensagem_meta := 'Meta SUPERADA!';
    ELSE
        p_mensagem_meta := 'Abaixo da meta ativa.';
    END IF;
END;
/

-- 2. COMO TESTAR NA PROVA (BLOCO ANÔNIMO OBRIGATÓRIO PARA OUT / IN OUT):
SET SERVEROUTPUT ON;
DECLARE
    -- Criamos as variáveis em memória (os envelopes) ANTES de chamar a procedure:
    v_minha_carga  NUMBER := 2;          -- Vai entrar valendo 2 e sair valendo 5!
    v_meu_resultado VARCHAR2(100);       -- Vai entrar vazio e sair com a mensagem!
BEGIN
    -- Passamos literais nos parâmetros IN (1, 1) e variáveis nos parâmetros IN OUT e OUT:
    PRC_VALIDAR_PROGRESSAO(1, 1, v_minha_carga, v_meu_resultado);

    DBMS_OUTPUT.PUT_LINE('Carga após validação: ' || v_minha_carga || ' kg');
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_meu_resultado);
END;
/
```

---

## 3.4 Regra Inegociável: Por que `OUT` e `IN OUT` DEVEM ser Variáveis de Memória (`PLS-00363`)

* **Pergunta Clássica:** *"Posso passar um número direto como `PRC_VALIDAR_PROGRESSAO(1, 1, 110, v_msg)` ou passar uma coluna de uma tabela direto no `OUT`?"*
* **Resposta:** **NUNCA!**
* **A Analogia do Envelope vs Parede de Tijolo:**  
  Como a procedure vai executar uma atribuição (`p_carga_proposta := ...`), ela precisa de um espaço de memória gravável (um envelope de papel). Se você passar o número literal `110`, você está entregando uma pedra sólida e mandando a procedure mudar o valor do número `110`. O número `110` sempre vale `110`! O Oracle bloqueia a compilação na hora com o erro:  
  **`PLS-00363: expression '110' cannot be used as an assignment target`**.  
  Por isso, sempre que houver `OUT` ou `IN OUT` na assinatura da procedure, **você é obrigado a abrir um bloco `DECLARE ... BEGIN ... END;` e criar uma variável para cada um deles!**

---

## 3.5 Operadores de Conjunto no SQL: `IN` e `NOT IN` com Subqueries

Não confunda o modo de parâmetro `IN` da Procedure com o **operador lógico `IN` / `NOT IN`** usado na cláusula `WHERE` das consultas SQL!

### 1. 🎟️ O Operador `IN` (A Lista de Convidados VIP)
Compara se o valor de uma coluna está presente dentro da lista de resultados devolvida por uma subquery:
```sql
SELECT NOME 
FROM TRE_USUARIO
WHERE ID_USUARIO IN (
    -- Subquery devolve uma lista de IDs (ex: 1, 3, 5):
    SELECT DISTINCT ID_USUARIO 
    FROM TRE_RECORD 
    WHERE CARGA_RECORD >= 100
);
```

### 2. 🚫 O Operador `NOT IN` (A Lista Negra) e a Armadilha Mortal do `NULL`
Filtra apenas os registros cujo ID **NÃO** aparece na lista da subquery (ideal para encontrar registros órfãos que nunca foram usados):

```sql
DELETE FROM TRE_TREINO
WHERE ID_TREINO NOT IN (
    SELECT ID_TREINO 
    FROM TRE_ITEM_TREINO
    WHERE ID_TREINO IS NOT NULL -- 🛡️ PROTEÇÃO OBRIGATÓRIA DE PROVA!
);
```

> 💀 **POR QUE O `WHERE coluna IS NOT NULL` É OBRIGATÓRIO DENTRO DO `NOT IN`?**  
> * No SQL, `X IN (1, 2, NULL)` equivale a `X = 1 OR X = 2 OR X = NULL`. Se `X` for `1`, `Verdadeiro OU Desconhecido` dá **Verdadeiro** (funciona normal).
> * Porém, `X NOT IN (1, 2, NULL)` equivale a **`X <> 1 AND X <> 2 AND X <> NULL`**.
> * No SQL, qualquer comparação com `NULL` usando `=` ou `<>` resulta em **`UNKNOWN` (Desconhecido)**. E `Verdadeiro E Desconhecido` resulta em **Desconhecido (Falso)**!
> * **Consequência prática:** Se houver **uma única linha com valor `NULL`** na subquery do `NOT IN`, a consulta inteira entra em pane silenciosa e **retorna ZERO linhas (não apaga nem mostra ninguém)**! Sempre blinde com `WHERE coluna IS NOT NULL`.

---

## 3.6 Subqueries Aninhadas em Comandos DML (`UPDATE`, `INSERT`, `DELETE`)

### 1. `UPDATE` em Lote com Subquery no `WHERE`:
```sql
UPDATE TRE_USUARIO
SET CATEGORIA = 'AVANÇADO'
WHERE ID_USUARIO IN (
    SELECT ID_USUARIO FROM TRE_RECORD WHERE CARGA_RECORD >= 100
);
```

### 2. `UPDATE` Multinível sem CTE (`CASE WHEN` + Subquery Escalar):
Quando você precisa atualizar uma coluna com vários níveis diferentes (ex: Iniciante, Intermediário, Avançado) de acordo com o cálculo de outra tabela, sem poder usar `WITH`:
* **A Analogia das Gavetinhas:** O `UPDATE` passa aluno por aluno. Para cada aluno (`u`), a subquery escalar abre a gaveta de recordes daquele aluno específico (`WHERE r.ID_USUARIO = u.ID_USUARIO`), pega o `MAX(CARGA_RECORD)` e o `CASE WHEN` decide qual carimbo bater:

```sql
UPDATE TRE_USUARIO u
SET CATEGORIA = CASE 
    WHEN (SELECT MAX(r.CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 100 THEN 'AVANÇADO'
    WHEN (SELECT MAX(r.CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 80  THEN 'INTERMEDIÁRIO'
    WHEN (SELECT MAX(r.CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 50  THEN 'INICIANTE'
    ELSE 'SEM CLASSIFICAÇÃO'
END;
```

> ⚠️ **Regra Gramatical do Oracle no `UPDATE` (Erro `ORA-01747`):**  
> No lado esquerdo do sinal de `=` dentro da cláusula `SET`, **NUNCA coloque o apelido da tabela** (`SET CARGA_RECORD = ...` é o certo; `SET r.CARGA_RECORD = ...` estoura o erro `ORA-01747: invalid table.column specification`). O apelido `r.` só é usado do lado direito do `=` e no `WHERE`!

### 3. `INSERT INTO ... SELECT` (Mantendo Códigos Sequenciais `SER-001` / `REC-001`):
Para inserir dados em uma tabela buscando de outra (ou gerando o próximo código sequencial do padrão do banco):
```sql
-- Descobrindo o último número de um código no formato 'SER-001':
-- SUBSTR(COD_SERIE, 5) corta a partir do 5º caractere ('001')
-- TO_NUMBER('001') transforma no número 1
SELECT NVL(MAX(TO_NUMBER(SUBSTR(COD_SERIE, 5))), 0)
INTO v_ult_numero
FROM TRE_SERIE;

-- Montando o novo código com zeros à esquerda ('SER-' + '002'):
v_novo_codigo := 'SER-' || LPAD(v_ult_numero + 1, 3, '0');
```
E quando for inserir múltiplas linhas de uma vez via `INSERT INTO ... SELECT`, basta somar `+ ROWNUM` ao último número:  
`'REC-' || LPAD(v_ult_numero + ROWNUM, 3, '0')`.

---

## 3.7 O Contador Secreto do Oracle: `SQL%ROWCOUNT`

Toda vez que um comando `INSERT`, `UPDATE` ou `DELETE` termina de rodar dentro de uma Procedure, o Oracle preenche automaticamente uma variável interna chamada **`SQL%ROWCOUNT`** com o número exato de linhas que foram afetadas por aquele comando!

```sql
DELETE FROM TRE_TREINO
WHERE ID_TREINO NOT IN (
    SELECT ID_TREINO FROM TRE_ITEM_TREINO WHERE ID_TREINO IS NOT NULL
);

-- Mostra quantos registros foram realmente apagados:
DBMS_OUTPUT.PUT_LINE('Total de treinos órfãos excluídos: ' || SQL%ROWCOUNT);

-- Ou pode ser usado em um IF para validar se o INSERT/UPDATE funcionou:
IF SQL%ROWCOUNT >= 1 THEN
    p_status := 'Operação realizada com sucesso!';
ELSE
    p_status := 'Nenhum registro foi afetado.';
END IF;
```

---
---

# PARTE 4: FUNCTIONS NO SELECT, %ROWTYPE, VIGÊNCIA TEMPORAL E MODULARIZAÇÃO (DIA 4)

## 4.1 A Batalha Definitiva: `PROCEDURE` vs `FUNCTION`

| Critério | `PROCEDURE` (O Mecânico / Instrutor) | `FUNCTION` (A Máquina de Refrigerante / Fórmula do Excel) |
| :--- | :--- | :--- |
| **Objetivo Principal** | Executar processos, alterar dados nas tabelas (`INSERT`, `UPDATE`, `DELETE`) e imprimir relatórios. | Calcular, transformar ou buscar um dado e **devolver obrigatoriamente uma resposta única**. |
| **Cabeçalho** | `CREATE OR REPLACE PROCEDURE nome (...) IS` | `CREATE OR REPLACE FUNCTION nome (...) RETURN tipo IS` |
| **Corpo (`BEGIN...END`)** | Não devolve valor por `RETURN` (usa `OUT` se precisar devolver algo). | **Obrigatório** ter `RETURN variavel_ou_valor;` no final! |
| **Pode ser chamada dentro de um `SELECT`?** | ❌ **JAMAIS!** | ✅ **SIM!** (`SELECT NOME, FNC_CALCULO(ID) FROM ...`) |
| **Como é chamada no PL/SQL?** | Chamada solta como um comando: `PRC_NOME(parametros);` | Chamada atribuindo o retorno a uma variável: `v_res := FNC_NOME(parametros);` |

---

## 4.2 As 3 Leis de Ouro das `FUNCTIONS` Usadas em `SELECT`

Pense no comando `SELECT` como uma planilha do Excel: cada linha e coluna espera receber um valor imediato (como `=SOMA(A1:A5)`). Para que uma `FUNCTION` possa ser chamada dentro de um `SELECT` (ou dentro do `SET`/`WHERE` de um `UPDATE`), ela deve obedecer a **3 leis absolutas do Oracle**:

1. **Proibido ter parâmetros `OUT` ou `IN OUT` (Erro `ORA-06572`):**  
   Se você colocar um parâmetro `OUT` em uma Function (ex: querendo devolver a carga pelo `RETURN` e a data pelo `OUT`), ela **perde a capacidade de ser chamada no `SELECT`** (`ORA-06572: Function has out arguments`). O comando `SELECT` não tem variáveis declaradas em memória para receber parâmetros `OUT`. Toda Function para SQL deve ter **apenas parâmetros `IN`**!
2. **Proibido executar comandos DML (`INSERT`, `UPDATE`, `DELETE`) dentro da Function (Erro `ORA-14551`):**  
   Uma consulta `SELECT` é uma operação de leitura. O Oracle proíbe que uma função chamada durante um `SELECT` altere tabelas do banco (`ORA-14551: cannot perform a DML operation inside a query`).
3. **Regra do Tamanho do Tipo de Retorno:**  
   * No cabeçalho da Function (`RETURN VARCHAR2` ou `RETURN NUMBER`), **NUNCA coloque parênteses de tamanho** (escrever `RETURN VARCHAR2(100)` dá erro de compilação!).
   * Já nas variáveis locais declaradas entre o `IS` e o `BEGIN` (`v_mensagem VARCHAR2(100);`), **é obrigatório colocar o tamanho** no `VARCHAR2`!

---

## 4.3 Anatomia Completa de uma `FUNCTION` e o Perigo do `CASE` sem `ELSE`

```sql
CREATE OR REPLACE FUNCTION FNC_STATUS_PROGRESSO_META (
    p_id_meta IN TRE_META.ID_META%TYPE
) RETURN VARCHAR2 -- <-- Sem tamanho no RETURN do cabeçalho!
IS
    v_mensagem     VARCHAR2(100); -- <-- Com tamanho obrigatório na variável local!
    v_id_usuario   TRE_META.ID_USUARIO%TYPE;
    v_id_exercicio TRE_META.ID_EXERCICIO%TYPE;
    v_carga_alvo   TRE_META.CARGA_ALVO%TYPE;
    v_max_record   TRE_RECORD.CARGA_RECORD%TYPE;
    v_percentual   NUMBER;
BEGIN
    -- 1. Busca os dados da meta
    SELECT ID_USUARIO, ID_EXERCICIO, CARGA_ALVO
    INTO v_id_usuario, v_id_exercicio, v_carga_alvo
    FROM TRE_META
    WHERE ID_META = p_id_meta;

    -- 2. Busca o maior recorde daquele aluno naquele exercício
    SELECT MAX(CARGA_RECORD)
    INTO v_max_record
    FROM TRE_RECORD
    WHERE ID_USUARIO = v_id_usuario
      AND ID_EXERCICIO = v_id_exercicio;

    -- 3. Calcula o percentual protegendo divisão por zero com NULLIF
    v_percentual := (v_max_record / NULLIF(v_carga_alvo, 0)) * 100;

    -- 4. Classifica com CASE procedural
    CASE
        WHEN v_percentual >= 100 THEN v_mensagem := 'CONCLUIDA';
        WHEN v_percentual >= 80 AND v_percentual < 100 THEN v_mensagem := 'FALTA POUCO';
        WHEN v_percentual < 80 THEN v_mensagem := 'EM PROGRESSO';
        ELSE v_mensagem := 'SEM REGISTRO'; -- <-- ELSE SALVADOR DE VIDAS!
    END CASE;

    -- 5. Devolve o resultado para a célula do SELECT
    RETURN v_mensagem;
END;
/

-- Chamando a Function direto no SELECT:
SELECT COD_META, CARGA_ALVO, FNC_STATUS_PROGRESSO_META(ID_META) AS SITUACAO
FROM TRE_META;
```

> 🚨 **A Pegadinha Mortal do `CASE` no PL/SQL (Erro `ORA-06592`):**  
> * No SQL comum (`SELECT CASE WHEN ... END`), se nenhuma condição for verdadeira e não houver `ELSE`, o banco devolve `NULL` silenciosamente.
> * Mas no **PL/SQL procedural (`CASE ... END CASE;`)**, se um aluno não tiver recorde (`v_max_record` for `NULL`, tornando `v_percentual` `NULL`), nenhuma das três condições `WHEN` será verdadeira. Se você esquecer de escrever o **`ELSE`**, o Oracle aborta a execução com o erro fatal:  
>   **`ORA-06592: CASE not found while executing CASE statement`**.  
> * **Regra de Sobrevivência:** Todo `CASE` dentro de Procedure ou Function **DEVE ter um `ELSE`**!

---

## 4.4 O Casamento entre Meta, Recorde e Série (A Linha do Tempo da Vigência Temporal)

Olhando para o script DDL do seu banco, a tabela `TRE_RECORD` **não possui** uma coluna `ID_META` nem `ID_SERIE`. Então como a gente descobre **quantos recordes foram batidos durante uma meta** ou **em qual série o recorde nasceu**?

### 1. 🎟️ Conectando `TRE_META` e `TRE_RECORD` (A Analogia do Plano de Academia)
Imagine um plano de academia que começou em `DATA_CRIACAO` e terminou em `DATA_CONCLUSAO` (ou ainda está valendo até hoje, `SYSDATE`, ou até `DATA_ALVO`, se `DATA_CONCLUSAO` for nula).
Um recorde pertence àquela meta se:
1. For do **mesmo usuário**: `r.ID_USUARIO = m.ID_USUARIO`
2. For do **mesmo exercício**: `r.ID_EXERCICIO = m.ID_EXERCICIO`
3. Tiver sido batido **dentro da janela de datas da meta**:  
   **`r.DATA_RECORD BETWEEN m.DATA_CRIACAO AND NVL(m.DATA_CONCLUSAO, SYSDATE)`**

#### 💻 Exemplo em Código Comentado (`VIEW` / `SELECT` de Metas x Recordes na Vigência):
```sql
CREATE OR REPLACE VIEW VW_METAS_E_RECORDES_VIGENCIA AS
SELECT 
    m.COD_META,
    u.NOME AS USUARIO,
    e.NOME AS EXERCICIO,
    m.CARGA_ALVO,
    m.STATUS,
    -- Conta quantos recordes foram batidos dentro da validade dessa meta
    COUNT(r.ID_RECORD) AS QTD_RECORDES_NA_META,
    -- Pega o maior recorde atingido durante a vigência dessa meta (ou 0 se não bateu nenhum)
    NVL(MAX(r.CARGA_RECORD), 0) AS MAIOR_RECORD_NA_VIGENCIA
FROM TRE_META m
INNER JOIN TRE_USUARIO u ON u.ID_USUARIO = m.ID_USUARIO
INNER JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = m.ID_EXERCICIO
-- LEFT JOIN para não sumir com as metas que ainda possuem 0 recordes batidos!
LEFT JOIN TRE_RECORD r 
    ON r.ID_USUARIO = m.ID_USUARIO                                              -- 1. Mesmo usuário
   AND r.ID_EXERCICIO = m.ID_EXERCICIO                                          -- 2. Mesmo exercício
   AND r.DATA_RECORD BETWEEN m.DATA_CRIACAO AND NVL(m.DATA_CONCLUSAO, SYSDATE)  -- 3. Dentro da linha do tempo!
GROUP BY 
    m.COD_META, u.NOME, e.NOME, m.CARGA_ALVO, m.STATUS;
```

---

### 2. 🔗 Conectando `TRE_RECORD` com a `TRE_SERIE` Exata que Gerou o Recorde
Se o professor pedir para descobrir em qual treino e em qual número de série aquele recorde foi batido:
1. O treino é do **mesmo usuário**: `t.ID_USUARIO = r.ID_USUARIO`
2. O treino aconteceu no **mesmo dia do recorde**: `TRUNC(t.DATA_TREINO) = TRUNC(r.DATA_RECORD)`
3. O item do treino é do **mesmo exercício**: `it.ID_EXERCICIO = r.ID_EXERCICIO`
4. A série teve **exatamente a mesma carga do recorde**: `s.CARGA = r.CARGA_RECORD`

#### 💻 Exemplo em Código Comentado (`SELECT` Rastreando a Série Exata onde o Recorde Nasceu):
```sql
SELECT 
    r.COD_RECORD,
    u.NOME AS USUARIO,
    e.NOME AS EXERCICIO,
    r.CARGA_RECORD,
    r.DATA_RECORD,
    t.COD_TREINO,          -- Qual foi a sessão de treino daquele dia
    s.COD_SERIE,           -- Qual o código da série exata
    s.NUMERO_SERIE,        -- Em qual número de série (1ª, 2ª, 3ª...) o recorde saiu
    s.REPETICOES           -- Quantas repetições ele fez com aquela carga recorde
FROM TRE_RECORD r
INNER JOIN TRE_USUARIO u ON u.ID_USUARIO = r.ID_USUARIO
INNER JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = r.ID_EXERCICIO
-- 1 e 2: Liga o recorde ao treino do mesmo aluno e que ocorreu no mesmo dia (TRUNC ignora horas)
INNER JOIN TRE_TREINO t 
    ON t.ID_USUARIO = r.ID_USUARIO
   AND TRUNC(t.DATA_TREINO) = TRUNC(r.DATA_RECORD)
-- 3: Liga ao item do treino que corresponde exatamente ao mesmo exercício do recorde
INNER JOIN TRE_ITEM_TREINO it 
    ON it.ID_TREINO = t.ID_TREINO
   AND it.ID_EXERCICIO = r.ID_EXERCICIO
-- 4: Liga à série exata onde a carga levantada bateu o valor do recorde!
INNER JOIN TRE_SERIE s 
    ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
   AND s.CARGA = r.CARGA_RECORD;
```

---

## 4.5 O Super Poder do `%ROWTYPE` (A Maleta de Ferramentas e a Caixa de Ovos)

* **`%TYPE` (A Chave de Fenda Avulsa):** Copia o tipo de **uma única coluna** (`v_nome TRE_USUARIO.NOME%TYPE`).
* **`%ROWTYPE` (A Maleta Completa da Tabela):** Cria uma variável composta que tem **todas as colunas de uma tabela inteira** já prontas dentro dela (`v_meta TRE_META%ROWTYPE`).

```sql
CREATE OR REPLACE FUNCTION FNC_RECORDES_NA_VIGENCIA_META (
    p_id_meta TRE_META.ID_META%TYPE
) RETURN NUMBER
AS
    v_meta       TRE_META%ROWTYPE; -- Maleta com todas as 9 colunas de TRE_META!
    v_qtd_record NUMBER;
BEGIN
    -- O SELECT * preenche todas as divisórias da maleta de uma vez só:
    SELECT *
    INTO v_meta
    FROM TRE_META
    WHERE ID_META = p_id_meta;

    -- Agora acessamos qualquer coluna usando "nome_da_maleta.NOME_DA_COLUNA":
    SELECT COUNT(r.ID_RECORD)
    INTO v_qtd_record
    FROM TRE_RECORD r
    WHERE r.ID_USUARIO = v_meta.ID_USUARIO
      AND r.ID_EXERCICIO = v_meta.ID_EXERCICIO
      AND r.DATA_RECORD BETWEEN v_meta.DATA_CRIACAO AND NVL(v_meta.DATA_CONCLUSAO, SYSDATE);

    RETURN NVL(v_qtd_record, 0);
END;
/
```

### 🥚 E se eu NÃO usar o `*` no `SELECT ... INTO` com `%ROWTYPE`? (A Caixa de Ovos - Erro `PLS-00386`)
A variável `v_meta TRE_META%ROWTYPE` é uma **caixa de 9 ovos** (possui 9 espaços exatos, um para cada coluna da tabela `TRE_META`).
* ❌ **O que dá erro:** Se você escrever `SELECT ID_META, COD_META INTO v_meta FROM TRE_META...`, você está tentando jogar apenas 2 ovos na caixa inteira de 9 lugares. O Oracle bloqueia na hora com `ORA-00947: not enough values` ou `PLS-00386: type mismatch`.
* ✅ **As 2 formas certas:**
  1. Usar **`SELECT * INTO v_meta`** (preenche os 9 ovos de uma vez e você só usa no código os campos que precisar).
  2. Ou apontar explicitamente para o buraquinho específico no `INTO` usando ponto:  
     `SELECT ID_USUARIO, CARGA_ALVO INTO v_meta.ID_USUARIO, v_meta.CARGA_ALVO FROM TRE_META WHERE ...;`

---

## 4.6 Modularização Nível Prova: `PROCEDURE` Consumindo `FUNCTION` dentro do `UPDATE`

Um dos padrões prediletos do seu professor é:
1. Primeiro você cria uma **`FUNCTION`** que resolve um cálculo complexo (ex: `FNC_MAIOR_CARGA_USUARIO(p_id_usuario, p_id_exercicio)` que varre treinos, itens e séries e devolve a maior carga).
2. Depois você cria uma **`PROCEDURE`** que precisa atualizar a tabela `TRE_RECORD` sempre que a maior carga das séries superar o recorde atual, **reaproveitando a Function dentro do comando `UPDATE`**!

```sql
CREATE OR REPLACE PROCEDURE PRC_ATUALIZAR_RECORDES_USUARIO (
    p_id_usuario TRE_USUARIO.ID_USUARIO%TYPE
) IS
BEGIN
    UPDATE TRE_RECORD r
    SET CARGA_RECORD = FNC_MAIOR_CARGA_USUARIO(p_id_usuario, r.ID_EXERCICIO),
        DATA_RECORD  = TRUNC(SYSDATE)
    WHERE r.ID_USUARIO = p_id_usuario
      AND FNC_MAIOR_CARGA_USUARIO(p_id_usuario, r.ID_EXERCICIO) > r.CARGA_RECORD;

    DBMS_OUTPUT.PUT_LINE('Recordes superados e atualizados: ' || SQL%ROWCOUNT);
END;
/
```

### 🏭 Como o Oracle sabe qual `r.ID_EXERCICIO` passar para a Function se a Procedure só recebeu `p_id_usuario`? (A Analogia da Esteira Rolante)
Essa é a mágica do SQL orientado a conjuntos:
1. Quando o `UPDATE TRE_RECORD r WHERE r.ID_USUARIO = 1` começa a rodar, o Oracle coloca todas as linhas de recordes do usuário 1 em uma **esteira rolante de fábrica**.
2. Passa a **1ª linha** da tabela na esteira: é o recorde do exercício `1` (Supino) com carga `90 kg`.  
   Nesse instante, para o Oracle, `r.ID_EXERCICIO` vale `1` e `r.CARGA_RECORD` vale `90`.  
   O próprio motor do SQL chama a sua função passando `(1, 1)`. Se a função devolver `100`, como `100 > 90`, ele atualiza a linha!
3. Passa a **2ª linha** na esteira: é o recorde do exercício `4` (Agachamento).  
   Agora `r.ID_EXERCICIO` vale `4`. O Oracle chama `FNC_MAIOR_CARGA_USUARIO(1, 4)` automaticamente!
4. Você **não precisa criar loop** e não precisa passar o ID do exercício na chamada da Procedure se quiser atualizar todos os exercícios daquele usuário de uma só vez: a própria linha `r` da tabela fornece o `r.ID_EXERCICIO` para a Function!
*(E se a questão pedir para atualizar apenas 1 exercício específico por vez, basta colocar `p_id_exercicio IN NUMBER` nos parâmetros da Procedure e adicionar `AND r.ID_EXERCICIO = p_id_exercicio` no `WHERE`).*

---

### 🧩 O Padrão Clássico da Atividade em Grupo: Procedure V1 (Com `JOIN` Manual) $\rightarrow$ Function $\rightarrow$ Procedure V2 (Com Function no `FROM`)

Veja a evolução exata cobrada em sala de aula para encontrar o treino que possui a maior quantidade de séries:

```sql
-- ============================================================================
-- PASSO 1: PROCEDURE V1 (Fazendo o JOIN e GROUP BY manualmente duas vezes)
-- ============================================================================
CREATE OR REPLACE PROCEDURE TREINO_MAX_SERIE IS
    v_qtd_maior INTEGER;
    v_id_treino INTEGER;
BEGIN
    -- 1º SELECT INTO: Descobre qual é o maior número de séries em um treino
    SELECT MAX(QTD_SERIE)
    INTO v_qtd_maior
    FROM (
        SELECT 
            t.ID_TREINO,
            COUNT(s.ID_SERIE) AS QTD_SERIE 
        FROM TRE_TREINO t
        INNER JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
        INNER JOIN TRE_SERIE s ON it.ID_ITEM_TREINO = s.ID_ITEM_TREINO
        GROUP BY t.ID_TREINO
    );

    -- 2º SELECT INTO: Descobre o ID do treino dono dessa maior quantidade
    -- (Usa MIN(ID_TREINO) para blindar a cadeira única contra empates!)
    SELECT MIN(ID_TREINO)
    INTO v_id_treino
    FROM (
        SELECT 
            t.ID_TREINO,
            COUNT(s.ID_SERIE) AS QTD_SERIE
        FROM TRE_TREINO t
        INNER JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
        INNER JOIN TRE_SERIE s ON it.ID_ITEM_TREINO = s.ID_ITEM_TREINO
        GROUP BY t.ID_TREINO
    )
    WHERE QTD_SERIE = v_qtd_maior;

    DBMS_OUTPUT.PUT_LINE('ID do treino: ' || v_id_treino || ' | Maior qtd de séries: ' || v_qtd_maior);
END;
/

-- ============================================================================
-- PASSO 2: CRIANDO A FUNCTION QUE ISOLA A CONTAGEM DE SÉRIES DE UM TREINO
-- ============================================================================
CREATE OR REPLACE FUNCTION COUNT_SERIES_TREINO (
    p_cod_treino VARCHAR2
) RETURN INTEGER IS
    v_id_treino    INTEGER;
    v_qtd_serie_id INTEGER;
BEGIN
    -- Traduz o COD_TREINO recebido para o ID_TREINO numérico
    SELECT ID_TREINO INTO v_id_treino
    FROM TRE_TREINO
    WHERE COD_TREINO = p_cod_treino;

    -- Conta as séries daquele treino específico
    SELECT COUNT(s.ID_SERIE)
    INTO v_qtd_serie_id
    FROM TRE_SERIE s
    INNER JOIN TRE_ITEM_TREINO it ON it.ID_ITEM_TREINO = s.ID_ITEM_TREINO
    WHERE it.ID_TREINO = v_id_treino;

    RETURN v_qtd_serie_id;
END;
/

-- ============================================================================
-- PASSO 3: PROCEDURE V2 (Substituindo os JOINs e GROUP BY pela Function!)
-- ============================================================================
CREATE OR REPLACE PROCEDURE TREINO_MAX_SERIE2 IS
    v_qtd_maior INTEGER;
    v_id_treino INTEGER;
BEGIN
    -- Olhe como a subquery do FROM ficou 10x menor usando a Function:
    SELECT MAX(QTD_SERIE)
    INTO v_qtd_maior
    FROM (
        SELECT COUNT_SERIES_TREINO(COD_TREINO) AS QTD_SERIE
        FROM TRE_TREINO
    );

    SELECT MIN(ID_TREINO)
    INTO v_id_treino
    FROM (
        SELECT 
            ID_TREINO,
            COUNT_SERIES_TREINO(COD_TREINO) AS QTD_SERIE
        FROM TRE_TREINO
    )
    WHERE QTD_SERIE = v_qtd_maior;

    DBMS_OUTPUT.PUT_LINE('ID do treino: ' || v_id_treino || ' | Maior qtd de séries: ' || v_qtd_maior);
END;
/
```

