# 🏋️ DIA 1: Anti-Produto Cartesiano & Subqueries Aninhadas no SELECT e FROM
> **Meta de Tempo:** 1h30 a 2h | **Foco:** Prática real no Oracle SQL (`TRE_`)

---

## 🧠 PARTE 1: O GUIA DEFINITIVO (DIDÁTICA E ATALHOS MENTAIS)

---

### 1.1 O Mapa Mental do seu Banco: Como as Tabelas se Conectam de Verdade

Antes de escrever qualquer código, você precisa entender o caminho que o dado faz no seu banco:

```
[TRE_USUARIO] 
      │ (1:N - cria treinos)
      ▼
[TRE_TREINO] 
      │ (1:N - adiciona exercícios ao treino)
      ▼
[TRE_ITEM_TREINO] ─── (N:1) ──► [TRE_EXERCICIO]
      │
      │ (1:N - faz repetições e bota peso)
      ▼
 [TRE_SERIE] (onde a CARGA realmente existe!)
```

> ⚠️ **PEGADINHA CLÁSSICA DE PROVA NO SEU BANCO:**  
> A tabela `TRE_EXERCICIO` tem uma coluna chamada `ID_USUARIO`. **Cuidado!** Aquilo serve apenas para dizer qual usuário foi o "autor" de um exercício personalizado (ex: Gabriel criou o *Agachamento Búlgaro*). Isso **NÃO** significa que ele treinou aquele exercício!  
> Para saber se o aluno realmente treinou e puxou peso, o único caminho real é:  
> **`TRE_USUARIO` $\rightarrow$ `TRE_TREINO` $\rightarrow$ `TRE_ITEM_TREINO` $\rightarrow$ `TRE_SERIE`**.

---

### 1.2 O que é o Produto Cartesiano e por que ele destrói sua consulta?

* **A Analogia das Pizzas:**  
  Se você tem uma lista com 3 amigos e uma lista com 4 sabores de pizza, e cruzar as duas sem regra nenhuma, o resultado terá $3 \times 4 = 12$ linhas. Isso é multiplicar tudo por tudo.
* **O Perigo Real no Banco (O Fan-Out Trap):**  
  - O Lucas tem **3 metas** cadastradas no Supino (`TRE_META`).
  - O Lucas tem **4 recordes** batidos no Supino (`TRE_RECORD`).
  - O Lucas fez **10 séries** de Supino (`TRE_SERIE`).  
  
  Se você fizer um `JOIN` seco entre essas três tabelas filhas ao mesmo tempo:  
  O banco vai multiplicar $3 \times 4 \times 10 = \mathbf{120 \text{ linhas!}}$  
  Cada série vai se repetir 12 vezes. Se você der um `SUM(CARGA)` ou um `COUNT(*)`, seu resultado estará **completamente errado** e o professor zera a questão.

---

### 1.3 As Duas Formas de Resolver: Subqueries Aninhadas

Para evitar a explosão de linhas, usamos **subqueries aninhadas** (perguntas isoladas dentro do SQL principal). Existem duas formas que você precisa dominar:

---

#### 📌 FORMA 1: Subquery no SELECT (A Analogia da Célula do Excel)

* **O Conceito:**  
  Em uma planilha do Excel, dentro de um único quadradinho (célula) de uma linha, você só consegue colocar **um único valor** (um número ou um texto). Você nunca consegue colocar uma tabela de 10 linhas dentro de uma célula só.
* **Como o banco pensa:**  
  Quando você enfia um `(SELECT ...)` no lugar de uma coluna, o banco exige que aquela pergunta devolva **uma única resposta** para caber na célula daquela linha.

```sql
SELECT 
    u.NOME,
    -- Pergunta personalizada: devolve 1 número para a célula
    (SELECT COUNT(*) FROM TRE_META m WHERE m.ID_USUARIO = u.ID_USUARIO) AS TOTAL_METAS,
    -- Pergunta personalizada: devolve 1 número para a célula
    (SELECT COUNT(*) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) AS TOTAL_RECORDES
FROM TRE_USUARIO u;
```

* **Dúvida de Ouro: Por que essa consulta não repete linhas iguais? (A Analogia da Chamada Escolar):**
  * Se a subquery fosse genérica (sem o `WHERE m.ID_USUARIO = u.ID_USUARIO`), seria como o professor perguntar para a sala inteira: *"Quantos alunos tem na escola?"*. Ele perguntaria isso 10 vezes e ouviria a mesma resposta 10 vezes.
  * Mas como tem o `WHERE m.ID_USUARIO = u.ID_USUARIO`, é uma **pergunta personalizada**: o professor olha para o **Lucas** e pergunta *"quantas metas VOCÊ tem?"* (responde 3). Passa para o **Gabriel** e pergunta *"quantas metas VOCÊ tem?"* (responde 2). Cada linha recebe o seu próprio dado!

---

#### 📌 FORMA 2: Subquery no FROM = Uma "VIEW Temporária" (A Analogia do Post-It)

**ESTE É O MAIOR ATALHO MENTAL QUE VOCÊ VAI APRENDER:**  
> **Uma subquery dentro do `FROM` nada mais é do que uma `VIEW` temporária (no manual da Oracle chama-se *Inline View*)!**

* **A Analogia do Caderno vs Post-it:**
  * Uma **`VIEW` comum** (`CREATE VIEW vw_nome AS SELECT ...`) é uma receita anotada no seu **caderno fixo**: ela fica gravada para sempre no banco.
  * Uma **Subquery no `FROM`** é um **Post-it temporário**: você faz um rascunho na hora entre parênteses, usa naquela consulta e, assim que o resultado sai na tela, o Post-it é jogado fora da memória.

Veja este exemplo clássico de como ela funciona com o **Crachá**, o **Compactador** e a **Ligação**:

```sql
SELECT 
    u.NOME,
    NVL(metas.TOTAL_METAS, 0) AS TOTAL_METAS,
    NVL(records.TOTAL_RECORDES, 0) AS TOTAL_RECORDES
FROM TRE_USUARIO u

-- TABELA RESUMIDA 1: Metas compactadas por usuário
LEFT JOIN (
    SELECT 
        ID_USUARIO,            -- 1. O CRACHÁ: Precisamos dele aqui para conseguir ligar no ON lá fora!
        COUNT(*) AS TOTAL_METAS
    FROM TRE_META
    GROUP BY ID_USUARIO        -- 2. O COMPACTADOR: Transforma as 10 metas do Lucas em apenas 1 linha resumida!
) metas ON metas.ID_USUARIO = u.ID_USUARIO  -- 3. A LIGAÇÃO: Liga o Lucas daqui com o Lucas de lá

-- TABELA RESUMIDA 2: Recordes compactados por usuário
LEFT JOIN (
    SELECT 
        ID_USUARIO,            -- O crachá de identificação
        COUNT(*) AS TOTAL_RECORDES
    FROM TRE_RECORD
    GROUP BY ID_USUARIO        -- Garante que cada usuário só tenha 1 linha aqui dentro
) records ON records.ID_USUARIO = u.ID_USUARIO;
```

> 💡 **Por que o `ID_USUARIO` é obrigatório dentro da subquery? (A Analogia do Crachá)**
> 1. **Para compactar:** O `GROUP BY ID_USUARIO` junta todas as linhas daquele usuário e transforma em **uma única linha de resumo**.
> 2. **Para colar a etiqueta com o nome:** Se a subquery calculasse apenas `COUNT(*)`, ela devolveria um número, mas a tabela principal lá fora perguntaria: *"Legal, esse total de 5 metas é de quem? Do Lucas? Do Gabriel?"*. Sem o `ID_USUARIO` no `SELECT` da subquery, o `ON` não tem como ligar a pessoa certa ao seu respectivo total!
> 
> Como o resumo tem **1 linha por usuário**, cruzar $1 \times 1$ no `JOIN` nunca multiplica linhas! Zero produto cartesiano!

---

#### 🛠️ O Método Infalível em 3 Passos (Aplicado aos Treinos e Séries):

* **Passo 1: Escreva a subquery sozinha (o rascunho isolado)**  
  Gere primeiro a tabelinha enxuta que resume o problema:
  ```sql
  SELECT 
      t.ID_USUARIO,
      it.ID_EXERCICIO,
      MAX(s.CARGA) AS MAIOR_CARGA
  FROM TRE_TREINO t
  JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
  JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
  GROUP BY t.ID_USUARIO, it.ID_EXERCICIO;
  ```
  *(Isso devolve exatamente 1 linha por par Usuário/Exercício com a maior carga).*

* **Passo 2: Envelopa entre parênteses no `FROM` e dá um apelido (o Post-it batizado)**  
  ```sql
  FROM (
      SELECT t.ID_USUARIO, it.ID_EXERCICIO, MAX(s.CARGA) AS MAIOR_CARGA
      FROM TRE_TREINO t
      JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
      JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
      GROUP BY t.ID_USUARIO, it.ID_EXERCICIO
  ) resumo
  ```

* **Passo 3: Faça os `JOIN`s normais com ela como se fosse uma tabela comum!**  
  Agora que o `resumo` está na sua mesa com os IDs e a maior carga, você liga:
  * Com `TRE_USUARIO u` por `u.ID_USUARIO = resumo.ID_USUARIO` (para pegar o nome do aluno).
  * Com `TRE_EXERCICIO e` por `e.ID_EXERCICIO = resumo.ID_EXERCICIO` (para pegar o nome do exercício).
  * Com `TRE_META m` por `m.ID_USUARIO = resumo.ID_USUARIO AND m.ID_EXERCICIO = resumo.ID_EXERCICIO` (para pegar a meta ativa dele).

* **Por que o `ID_USUARIO` e o `ID_EXERCICIO` são obrigatórios dentro da subquery? (A Analogia do Crachá):**  
  O `GROUP BY` serve como compactador (junta todas as repetições em 1 linha só). E o `ID` no `SELECT` serve como o crachá: sem ele, quem está lá fora não tem como saber a quem pertence aquele total!

---

### 1.4 A Tabela `DUAL` (A Analogia da Esteira de Fábrica)

No Oracle, todo comando `SELECT` é **obrigado** por sintaxe a ter a cláusula `FROM`.
Pense no `FROM` como uma **esteira de fábrica**:
* Se você colocar `FROM TRE_USUARIO`, a esteira passa com 10 caixas (uma para cada usuário). Se você fizer uma pergunta genérica, o banco vai carimbar e imprimir a mesma resposta 10 vezes.
* A **`DUAL`** é uma tabela especial de mentira que tem **apenas 1 linha e 1 coluna**.
* Logo, ao colocar `FROM DUAL`, a esteira roda **uma única vez**: calcula, carimba uma única linha na tela e encerra!

---

### 1.5 Funções Auxiliares de Tratamento (Limpando Nulos e Textos)

| Função | O que ela faz na prática | Exemplo Prático |
| :--- | :--- | :--- |
| **`NVL(campo, substituto)`** | Se o campo vier nulo (vazio do `LEFT JOIN`), troca pelo substituto. | `NVL(m.CARGA_ALVO, 0)` $\rightarrow$ Se não tiver meta, mostra 0 em vez de branco. |
| **`COALESCE(c1, c2, ...)`** | Padrão ANSI. Devolve o primeiro valor não-nulo da lista. | `COALESCE(m.CARGA_ALVO, 0)` |
| **`UPPER(texto)`** | Transforma em MAIÚSCULAS para não errar no `LIKE`. | `WHERE UPPER(NOME) LIKE 'G%'` |

---

## 📝 PARTE 2: ATIVIDADES PRÁTICAS DO DIA 1

---

### 🎯 EXERCÍCIO 1
Crie um comando `SELECT` que retorne, em uma única linha:
* `QTD_USUARIOS_G`: Total de usuários cujo nome começa com a letra 'G'.
* `QTD_EXERCICIOS_S`: Total de exercícios cujo nome começa com a letra 'S'.

**Exigências:**
* Usar subqueries no `SELECT` a partir da tabela `DUAL`.
* Fazer a busca sem diferenciar maiúsculas e minúsculas (`UPPER`).

💡 **Dica de Raciocínio:** Cada subquery entre parênteses no `SELECT` deve responder uma pergunta independente (um único número) a partir da sua respectiva tabela de origem.

---

### 🎯 EXERCÍCIO 2
Crie um comando `SELECT` que retorne:
* Nome do usuário (`TRE_USUARIO`)
* Nome do exercício (`TRE_EXERCICIO`)
* Maior carga levantada nas séries desse exercício
* Carga alvo da meta ativa desse usuário para o exercício (ou `0` caso não possua meta ativa)

**Exigências:**
* Usar obrigatoriamente **subquery aninhada no `FROM`** para agrupar as séries antes de qualquer junção.
* Proibido gerar produto cartesiano (linhas duplicadas).
* Usar `NVL` para tratar metas inexistentes.

💡 **Dica de Raciocínio:** Monte primeiro a subquery no `FROM` que calcula o `MAX(CARGA)` agrupado por `ID_USUARIO` e `ID_EXERCICIO`. Do lado de fora, faça os `JOIN`s normais com as tabelas de nomes e o `LEFT JOIN` com `TRE_META` comparando ambos os IDs.

---

### 🎯 EXERCÍCIO 3
Crie um comando `SELECT` consultando a tabela `TRE_TREINO` que retorne:
* Código do treino (`COD_TREINO`)
* Data do treino (`DATA_TREINO`)
* Nome do usuário que treinou (`TRE_USUARIO`)
* Quantidade total de exercícios executados naquele treino
* Quantidade total de séries executadas naquele treino

**Exigências:**
* As contagens de exercícios e de séries devem ser resolvidas obrigatoriamente usando **subqueries aninhadas no `SELECT`**.

💡 **Dica de Raciocínio:** A primeira subquery conta os exercícios daquele treino em `TRE_ITEM_TREINO` (ligando por `ID_TREINO`). A segunda subquery conta as séries em `TRE_SERIE` filtrando os itens daquele treino específico.

---

### 🎯 EXERCÍCIO 4
Crie um comando `SELECT` que liste para cada usuário e exercício treinado:
* Nome do usuário
* Nome do exercício
* Carga do maior recorde registrado (`TRE_RECORD`), ou `0` se não houver
* Carga alvo da meta ativa (`TRE_META`), ou `0` se não houver
* Maior carga levantada nas séries (`TRE_SERIE`), ou `0` se não houver

**Exigências:**
* Cruzar os dados utilizando **subqueries aninhadas no `FROM`** para garantir zero produto cartesiano.
* Tratar valores nulos com `NVL`.

💡 **Dica de Raciocínio:** Crie uma subquery no `FROM` para o resumo das séries e outra subquery no `FROM` para o resumo dos recordes (ambas agrupadas por usuário e exercício). Junte as duas pelas chaves `ID_USUARIO` e `ID_EXERCICIO`.

---

## 🏆 PARTE 3: SUAS RESOLUÇÕES OFICIAIS (GABARITO DO DIA 1)

Você concluiu os 4 exercícios! Aqui está o seu código final salvo e validado:

```sql
-- ============================================================================
-- EXERCÍCIO 1: Subqueries no SELECT com DUAL
-- ============================================================================
SELECT 
    (SELECT COUNT(id_usuario) FROM tre_usuario WHERE UPPER(nome) LIKE 'G%') AS qtd_nome_G,
    (SELECT COUNT(id_exercicio) FROM tre_exercicio WHERE UPPER(nome) LIKE 'S%') AS qtd_exercicio_s
FROM DUAL;

-- ============================================================================
-- EXERCÍCIO 2: Subquery no FROM (View Temporária de Treino) + JOINs
-- ============================================================================
SELECT
    u.nome AS usuario,
    e.nome AS exercicio,
    resumo.carga_max,
    NVL(m.carga_alvo, 0) AS meta_ativa
FROM (
    SELECT
        t.id_usuario,
        it.id_exercicio,
        MAX(s.carga) AS carga_max
    FROM tre_treino t
    INNER JOIN tre_item_treino it ON it.id_treino = t.id_treino
    INNER JOIN tre_serie s ON it.id_item_treino = s.id_item_treino
    GROUP BY t.id_usuario, it.id_exercicio
) resumo
INNER JOIN tre_usuario u ON u.id_usuario = resumo.id_usuario
INNER JOIN tre_exercicio e ON e.id_exercicio = resumo.id_exercicio
LEFT JOIN tre_meta m ON m.id_usuario = u.id_usuario
                    AND m.id_exercicio = resumo.id_exercicio
                    AND m.status = 'ATIVA';

-- ============================================================================
-- EXERCÍCIO 3: Subqueries Correlacionadas no SELECT com Ponte de Treino
-- ============================================================================
SELECT
    t.cod_treino,
    t.data_treino,
    u.nome AS usuario,
    (SELECT COUNT(id_exercicio) 
     FROM tre_item_treino it 
     WHERE it.id_treino = t.id_treino) AS qtd_exercio,
    (SELECT COUNT(id_serie) 
     FROM tre_serie s 
     INNER JOIN tre_item_treino it ON s.id_item_treino = it.id_item_treino
     WHERE it.id_treino = t.id_treino) AS qtd_serie
FROM tre_treino t
INNER JOIN tre_usuario u ON u.id_usuario = t.id_usuario
ORDER BY t.cod_treino;

-- ============================================================================
-- EXERCÍCIO 4: Cruzando Séries e Recordes com Duas Subqueries no FROM
-- ============================================================================
SELECT 
    u.NOME AS USUARIO,
    e.NOME AS EXERCICIO,
    NVL(resumo_r.MAIOR_RECORD, 0) AS RECORDE_OFICIAL,
    NVL(m.CARGA_ALVO, 0) AS META_ATIVA,
    res_c_serie.MAIOR_CARGA_SERIE
FROM (
    -- Resumo das séries por Aluno e Exercício
    SELECT 
        t.ID_USUARIO,
        it.ID_EXERCICIO,
        MAX(s.CARGA) AS MAIOR_CARGA_SERIE
    FROM TRE_SERIE s
    JOIN TRE_ITEM_TREINO it ON it.ID_ITEM_TREINO = s.ID_ITEM_TREINO
    JOIN TRE_TREINO t ON t.ID_TREINO = it.ID_TREINO
    GROUP BY t.ID_USUARIO, it.ID_EXERCICIO
) res_c_serie
JOIN TRE_USUARIO u ON u.ID_USUARIO = res_c_serie.ID_USUARIO
JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = res_c_serie.ID_EXERCICIO
LEFT JOIN (
    -- Resumo dos recordes por Aluno e Exercício
    SELECT 
        r.ID_USUARIO,
        r.ID_EXERCICIO,
        MAX(r.CARGA_RECORD) AS MAIOR_RECORD
    FROM TRE_RECORD r
    GROUP BY r.ID_USUARIO, r.ID_EXERCICIO
) resumo_r ON resumo_r.ID_USUARIO = res_c_serie.ID_USUARIO 
          AND resumo_r.ID_EXERCICIO = res_c_serie.ID_EXERCICIO
LEFT JOIN TRE_META m ON m.ID_USUARIO = res_c_serie.ID_USUARIO 
                    AND m.ID_EXERCICIO = res_c_serie.ID_EXERCICIO
                    AND m.STATUS = 'ATIVA';
```

---

## 🚨 PARTE 4: PRINCIPAIS DIFICULDADES MAPEADAS NO DIA 1 & COMO NÃO ERRAR NA PROVA

Aqui está o raio-x das suas dúvidas de hoje para você revisar antes da prova:

### 1. "O que eu coloco no GROUP BY da Subquery no FROM?"
* **O Erro que você teve:** Querer agrupar por tudo (`id_serie`, `id_treino`, etc.), o que impede o banco de calcular o `MAX()` e deixa as linhas soltas.
* **A Regra de Ouro para a Prova:** Olhe o que você quer saber no final. Se você quer saber a maior carga do aluno por exercício, a resposta só depende de duas coisas: `ID_USUARIO` e `ID_EXERCICIO`. O `GROUP BY` só leva essas duas colunas!

### 2. "A Subquery no FROM pode ver tabelas de fora?"
* **O Erro que você teve:** Tentar fazer `WHERE r.id_exercicio = e.id_exercicio` dentro da subquery no `FROM`.
* **A Regra de Ouro para a Prova:** A subquery no `FROM` é uma **ilha isolada** (um Post-it fechado). Ela **NÃO** enxerga as tabelas de fora. Tudo o que ela precisa filtrar ou calcular tem que estar dentro dos parênteses dela mesma.

### 3. "Posso colocar duas subqueries no FROM separadas por vírgula?"
* **O Erro que você teve:** Escrever `FROM (subquery1) r, (subquery2) s`.
* **A Regra de Ouro para a Prova:** **NUNCA USE VÍRGULA NO FROM!** Vírgula no `FROM` é a definição de **Produto Cartesiano**. Além disso, se o aluno tiver feito séries mas não tiver recorde, a vírgula faz a linha dele sumir. Sempre use `LEFT JOIN subquery ON ...` para manter todos os registros visíveis e seguros.

### 4. "Subquery no SELECT que precisa de tabelas intermediárias:"
* **O Erro que você teve:** No Exercício 3, tentar chamar `tre_item_treino.id_item_treino` sem que ele existisse no `FROM` principal.
* **A Regra de Ouro para a Prova:** Quando a subquery no `SELECT` precisa de uma tabela que não está no `FROM` de fora, dê um `INNER JOIN` dentro da própria subquery para criar a ponte até a tabela principal.

---

### 🎓 Nível de Cobrança na Prova Real:
* **Exercício 1 e Exercício 3:** São o **padrão típico e mais provável** de prova de faculdade (perguntas no `SELECT`, subqueries com correlação e uso de `DUAL`). Você fez os dois com perfeição!
* **Exercício 2 e Exercício 4:** São o **nível avançado**. Se o seu professor tentar complicar a prova para diferenciar quem sabe modelar de quem só decorou, agora você já tem o mapa mental do Post-it temporário no `FROM` dominado.


