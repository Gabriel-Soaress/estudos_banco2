# ⚡ LISTA DE REVISÃO RÁPIDA: TESTES DE FIXAÇÃO INDIVIDUAL (BANCO DE DADOS II)

> **Objetivo:** Exercícios atômicos, diretos e rápidos para você testar cada conceito isoladamente antes do Simulado Geral de amanhã.  
> **Regras:** Proibido `WITH`, Proibido `UNION`, Proibido `EXCEPTION`.

---

### 🎯 TESTE 1: Anti-Produto Cartesiano com Subquery no SELECT
Crie uma consulta SQL que retorne o `NOME` do usuário e o total de treinos realizados por ele.

**Exigências:**
* Colunas retornadas: `NOME`, `TOTAL_TREINOS`.
* Proibido usar `GROUP BY` na consulta principal.
* Uso obrigatório de subquery escalar no `SELECT`.

💡 **Dica de Raciocínio:** O `SELECT` principal consulta `TRE_USUARIO`. Dentro dele, abra uma subquery entre parênteses calculando `COUNT(*)` em `TRE_TREINO` amarrando pelo `ID_USUARIO`.

---

### 🎯 TESTE 2: Subquery no FROM (Inline View)
Crie uma consulta SQL que retorne o `NOME` do usuário e a maior duração de treino registrada para ele.

**Exigências:**
* Colunas retornadas: `NOME`, `MAIOR_DURACAO`.
* Uso obrigatório de subquery aninhada no `FROM` com `LEFT JOIN`.
* Usar `NVL` para exibir `0` se o usuário não possuir treinos.

💡 **Dica de Raciocínio:** No `FROM`, crie uma tabela derivada entre parênteses agrupando `TRE_TREINO` por `ID_USUARIO` e calculando `MAX(DURACAO_MINUTO)`. Faça o `LEFT JOIN` com `TRE_USUARIO`.

---

### 🎯 TESTE 3: Agregação com GROUP BY e Filtro no HAVING
Crie uma consulta SQL que agrupe as séries por exercício e calcule a média de repetições, exibindo apenas exercícios com média superior a 10.

**Exigências:**
* Colunas retornadas: `ID_EXERCICIO`, `MEDIA_REPETICOES`.
* Média arredondada para 2 casas decimais usando `ROUND`.
* Filtro de agregação obrigatório no `HAVING`.

💡 **Dica de Raciocínio:** Junte `TRE_SERIE` com `TRE_ITEM_TREINO`, agrupe por `it.ID_EXERCICIO` e aplique `HAVING AVG(s.REPETICOES) > 10`.

---

### 🎯 TESTE 4: Pescando o Dono do Maior Valor com Subquery no WHERE
Crie uma consulta SQL que retorne o nome do usuário e o código do treino mais longo de todo o banco de dados.

**Exigências:**
* Colunas retornadas: `NOME`, `COD_TREINO`, `DURACAO_MINUTO`.
* Sem usar `GROUP BY` e sem usar `ORDER BY + ROWNUM`.
* Uso obrigatório de subquery no `WHERE`.

💡 **Dica de Raciocínio:** Junte `TRE_USUARIO` e `TRE_TREINO` e filtre com `WHERE t.DURACAO_MINUTO = (SELECT MAX(DURACAO_MINUTO) FROM TRE_TREINO)`.

---

### 🎯 TESTE 5: Criação de View Analítica
Crie uma View chamada **`VW_RESUMO_METAS_USUARIOS`** que exiba a contagem de metas ativas por usuário.

**Exigências:**
* Usar `CREATE OR REPLACE VIEW`.
* Colunas da View: `COD_USUARIO`, `NOME`, `QTD_METAS_ATIVAS`.
* Exibir todos os usuários (inclusive os que não possuem metas ativas, mostrando `0` com `NVL`).

💡 **Dica de Raciocínio:** Use `TRE_USUARIO` com `LEFT JOIN` em `TRE_META` adicionando a condição `AND m.STATUS = 'ATIVA'` na cláusula `ON` do join, agrupando por código e nome com `COUNT(m.ID_META)`.

---

### 🎯 TESTE 6: Procedure Básica com Parâmetros IN e OUT
Crie uma procedure chamada **`PRC_OBTER_CONTATO_USUARIO`** que receba:
* `p_id_usuario IN NUMBER`
* `p_nome OUT VARCHAR2`
* `p_email OUT VARCHAR2`

**Regras de Negócio da Procedure:**
1. Execute um comando `SELECT ... INTO ...` na tabela `TRE_USUARIO` buscando o nome e e-mail do usuário informado.
2. Escreva o bloco anônimo de teste com `DECLARE` para rodar a procedure e imprimir as saídas com `DBMS_OUTPUT.PUT_LINE`.

**Exigências:**
* Parâmetros `IN` e `OUT`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O corpo da procedure tem apenas o `SELECT NOME, EMAIL INTO p_nome, p_email FROM TRE_USUARIO WHERE ID_USUARIO = p_id_usuario;`. No bloco anônimo, declare as variáveis antes de passar para a chamada.

---

### 🎯 TESTE 7: Procedure com Parâmetro IN OUT (Saneamento de Dados)
Crie uma procedure chamada **`PRC_SANEAR_DURACAO_TREINO`** que receba:
* `p_duracao IN OUT NUMBER`

**Regras de Negócio da Procedure:**
1. Se `p_duracao < 15`, ajuste o valor para `15`.
2. Se `p_duracao > 180`, ajuste o valor para `180`.
3. Escreva o bloco anônimo de teste comprovando que a variável passada foi modificada.

**Exigências:**
* Uso correto do modo `IN OUT`.
* Condicional com `IF ... ELSIF`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O parâmetro `p_duracao` é reatribuído com `:=` dentro dos blocos `IF`.

---

### 🎯 TESTE 8: Function Escalar para Consumo no SELECT
Crie uma função chamada **`FNC_TOTAL_SERIES_ITEM`** que receba:
* `p_id_item_treino IN NUMBER`
* Retorno: `NUMBER`

**Regras de Negócio da Função:**
1. Conte quantas séries estão cadastradas na tabela `TRE_SERIE` para aquele item de treino específico.
2. Trate com `NVL` para garantir que retorne `0` se não houver séries.
3. Escreva um comando `SELECT` na tabela `TRE_ITEM_TREINO` exibindo `ID_ITEM_TREINO`, `ID_EXERCICIO` e a chamada da função como `TOTAL_SERIES`.

**Exigências:**
* Usar `CREATE OR REPLACE FUNCTION`.
* Retornar `NUMBER`.
* Apresentar a consulta `SELECT` que consome a função.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** A função executa `SELECT NVL(COUNT(*), 0) INTO v_total FROM TRE_SERIE WHERE ID_ITEM_TREINO = p_id_item_treino;` e finaliza com `RETURN v_total;`.

---

### 🎯 TESTE 9: DELETE Seguro com NOT IN e Proteção IS NOT NULL
Escreva um comando `DELETE` na tabela `TRE_EXERCICIO` que remova todos os exercícios que nunca foram utilizados em nenhum item de treino (`TRE_ITEM_TREINO`).

**Exigências:**
* Usar `WHERE ID_EXERCICIO NOT IN (SELECT ...)`.
* Incluir a proteção obrigatória contra nulos (`WHERE ID_EXERCICIO IS NOT NULL`).

💡 **Dica de Raciocínio:** O comando filtra os IDs da tabela pai que não aparecem na subquery da tabela filha, garantindo que a subquery nunca devolva `NULL`.
