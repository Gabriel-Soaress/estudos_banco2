# 🏋️ DIA 4: PL/SQL AVANÇADO (FUNCTIONS NO SELECT & PROCEDURES ROBUSTAS)

> **Carga Horária Recomendada:** 1h30 a 2h  
> **SGBD:** Oracle SQL & PL/SQL  
> **Banco Oficial:** `TRE_` (Sistema de Treinos e Metas)  
> **Regras Absolutas:** Proibido `WITH`, Proibido `UNION`, Proibido `EXCEPTION`.

---

## 🧭 MAPA DE APRENDIZADO DO DIA 4
Hoje você vai dominar a peça que falta para o seu arsenal de PL/SQL:
1. **A Diferença Crucial entre `PROCEDURE` e `FUNCTION`** (e por que uma pode entrar no `SELECT` e a outra não).
2. **Criação de `FUNCTIONS` Escalares** com `RETURN` obrigatório.
3. **Consumo de Functions dentro de consultas `SELECT`** (como se fossem fórmulas do Excel).
4. **Regras de Ouro de Segurança para Functions** (por que nunca fazer `INSERT/UPDATE` dentro de uma function de leitura).
5. **Combinação de `IN`, `OUT`, `IN OUT`, `CASE WHEN` e `SQL%ROWCOUNT`** em rotinas robustas.

---

## 📖 PARTE 1: FUNDAMENTOS DIDÁTICOS E ANALOGIAS

### 1.1 A Batalha: PROCEDURE vs FUNCTION

| Recurso | A Analogia do Cotidiano | Cláusula Obrigatória | Pode ser chamada no `SELECT`? | Objetivo Principal |
| :--- | :--- | :---: | :---: | :--- |
| **`PROCEDURE`** | **O Mecânico da Oficina / O Instrutor:** Você dá uma ordem ("troque o pneu", "limpe os registros"). Ele vai lá no motor/banco, mexe, altera tabelas, e não é obrigado a devolver nada na sua mão. | Nenhuma (pode usar `RETURN;` apenas para sair mais cedo) | ❌ **NUNCA** | Executar ações, processos, cálculos em lote e comandos DML (`INSERT`, `UPDATE`, `DELETE`). |
| **`FUNCTION`** | **A Máquina de Refrigerante / O Caixa Eletrônico:** Você coloca os parâmetros (moeda/cartão) e aperta o botão. Ela é **estritamente obrigada** a cuspir um resultado na sua mão. | `RETURN <tipo>` no cabeçalho e `RETURN <valor>;` no corpo | ✅ **SIM!** | Calcular, transformar ou classificar um dado e devolver um valor único para quem chamou. |

---

### 1.2 Por que apenas a FUNCTION pode ser chamada dentro do `SELECT`?

Pense no comando `SELECT` como uma planilha do **Excel**:
```
| NOME_USUARIO | MAIOR_CARGA (Excel Formula) |
| Carlos       | =CALCULAR_CARGA(id)        |
| Ana          | =CALCULAR_CARGA(id)        |
```
Cada célula do `SELECT` espera **exatamente um valor** (um número, um texto ou uma data).
* Uma **`FUNCTION`** sempre devolve um valor único (`RETURN 120.50`). Portanto, ela cabe perfeitamente dentro de uma célula do `SELECT`!
* Uma **`PROCEDURE`** não devolve nada por si só (ela apenas executa ações). O `SELECT` não sabe o que colocar na célula, gerando erro de compilação.

---

### 1.3 A Anatomia Perfeita de uma FUNCTION

```sql
CREATE OR REPLACE FUNCTION FNC_TOTAL_TREINOS_USUARIO (
    p_id_usuario IN NUMBER -- Apenas o parâmetro que realmente será usado!
) RETURN NUMBER          -- 1. DECLARA O TIPO DE RETORNO AQUI NO CABEÇALHO
IS
    v_total NUMBER := 0; -- Variável local para guardar o cálculo
BEGIN
    -- 2. CORPO DA FUNÇÃO: calcula o total de treinos do usuário
    SELECT COUNT(*)
    INTO v_total
    FROM TRE_TREINO
    WHERE ID_USUARIO = p_id_usuario;

    -- 3. OBRIGATÓRIO: CUSPIR O VALOR DE VOLTA
    RETURN v_total;
END;
/
```

#### Como chamar a Function:
1. **Direto em uma consulta `SELECT` (como fórmula do Excel):**
   ```sql
   SELECT NOME, FNC_TOTAL_TREINOS_USUARIO(ID_USUARIO) AS TOTAL_TREINOS
   FROM TRE_USUARIO;
   ```
2. **Dentro de um bloco anônimo ou Procedure:**
   ```sql
   v_valor := FNC_TOTAL_TREINOS_USUARIO(1);
   ```

---

### 1.4 A Regra de Ouro do Oracle: Functions Usadas em `SELECT` NÃO Fazem DML!
> ⚠️ **AVISO CRÍTICO PARA A PROVA:**  
> Se uma Function for criada para ser usada dentro de um comando `SELECT`, ela **NUNCA PODE EXECUTAR `INSERT`, `UPDATE` OU `DELETE`**!  
> O Oracle impede que uma leitura de dados altere dados ao mesmo tempo (evitando inconsistência). Se você tentar colocar um `UPDATE` dentro de uma Function e chamá-la num `SELECT`, o Oracle estoura o erro:  
> `ORA-14551: cannot perform a DML operation inside a query`.  
> *Portanto:* Functions para `SELECT` servem exclusivamente para **calcular e retornar dados**.

---

### 1.5 Controle de Fluxo Sem `EXCEPTION`
Como o seu professor proibiu o bloco `EXCEPTION`, como garantimos que uma Function nunca quebre?
1. **Sempre use `NVL` ou `COALESCE`** nas consultas agregadas para garantir que números nunca voltem nulos:  
   `SELECT NVL(MAX(CARGA), 0) INTO v_carga ...`
2. **Inicialize as variáveis com valores default:**  
   `v_retorno VARCHAR2(50) := 'NÃO ENCONTRADO';`
3. **Use `IF ... ELSIF ... ELSE`:** Garanta que todos os caminhos do código tenham um `RETURN`.

---

## 📝 PARTE 2: ATIVIDADES PRÁTICAS DO DIA 4

---

### 🎯 EXERCÍCIO 1 (Function Escalar com Agregação para Uso em SELECT)
Crie uma função chamada **`FNC_MAIOR_CARGA_USUARIO`** que receba:
* `p_id_usuario IN NUMBER`
* `p_id_exercicio IN NUMBER`

**Regras de Negócio da Função:**
1. A função deve retornar um `NUMBER`.
2. Ela deve calcular e retornar a maior carga (`MAX(s.CARGA)`) já realizada por esse usuário naquele exercício, buscando nas séries realizadas (`TRE_SERIE` ligada com `TRE_ITEM_TREINO` e `TRE_TREINO`).
3. Se o usuário nunca tiver realizado nenhuma série para aquele exercício, a função deve retornar `0`.
4. **Chamada obrigatória:** Escreva um comando `SELECT` na tabela `TRE_USUARIO` exibindo:
   * `COD_USUARIO`
   * `NOME`
   * A chamada da função **`FNC_MAIOR_CARGA_USUARIO(u.ID_USUARIO, 1)`** apelidada como `MAIOR_CARGA_SUPINO` (considerando o exercício 1).

**Exigências:**
* Usar `CREATE OR REPLACE FUNCTION`.
* Usar cláusula `RETURN` apropriada.
* Tratamento com `NVL` para não retornar `NULL`.
* Sem bloco `EXCEPTION`.
* Apresentar a consulta `SELECT` que consome a função.

💡 **Dica de Raciocínio:** No corpo da function, faça `SELECT NVL(MAX(s.CARGA), 0) INTO v_maior FROM TRE_TREINO t JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO WHERE t.ID_USUARIO = p_id_usuario AND it.ID_EXERCICIO = p_id_exercicio;` e finalize com `RETURN v_maior;`.

---

### 🎯 EXERCÍCIO 2 (Function com Regra de Negócio Condicional e CASE)
Crie uma função chamada **`FNC_STATUS_PROGRESSO_META`** que receba:
* `p_id_meta IN NUMBER`

**Regras de Negócio da Função:**
1. A função deve retornar um `VARCHAR2`.
2. Ela deve buscar em `TRE_META` a `CARGA_ALVO` e o maior recorde atual do usuário naquele mesmo exercício em `TRE_RECORD` (`CARGA_RECORD`).
3. Calcule o percentual atingido: $\text{Percentual} = \frac{\text{Carga Recorde}}{\text{Carga Alvo}} \times 100$.
4. Avalie o percentual com `CASE WHEN` ou `IF / ELSIF / ELSE` e retorne:
   * Se $\ge 100\%$: `'META CONCLUIDA'`
   * Se $\ge 80\%$ e $< 100\%$: `'QUASE LA'`
   * Se $< 80\%$: `'EM PROGRESSO'`
   * Se a meta não tiver recordes registrados ou a carga alvo for zero: `'SEM REGISTRO'`
5. **Chamada obrigatória:** Escreva um comando `SELECT` na tabela `TRE_META` exibindo:
   * `COD_META`
   * `CARGA_ALVO`
   * A chamada da função `FNC_STATUS_PROGRESSO_META(ID_META)` como `SITUACAO_ATUAL`.

**Exigências:**
* Usar `RETURN VARCHAR2`.
* Proteger divisão por zero (com `IF` ou `NULLIF`).
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** Busque a carga alvo da meta e, por subquery escalar ou join, o maior recorde correspondente. Se a carga alvo for maior que 0 e o recorde existir, faça o cálculo matemático e monte a condicional de retorno.

---

### 🎯 EXERCÍCIO 3 (Procedure Completa com Parâmetros IN, OUT e IN OUT)
Crie uma procedure chamada **`PRC_REGISTRAR_SERIE`** que receba:
* `p_id_item_treino IN NUMBER` (Parâmetro de entrada)
* `p_num_serie IN NUMBER` (Parâmetro de entrada)
* `p_carga IN OUT NUMBER` (Parâmetro de entrada e saída)
* `p_repeticoes IN OUT NUMBER` (Parâmetro de entrada e saída)
* `p_status_gravacao OUT VARCHAR2` (Parâmetro de saída)

**Regras de Negócio da Procedure:**
1. **Validações com `IN OUT`:**
   * Se `p_carga <= 0`, a procedure deve corrigir o valor na memória para `1.00` (`p_carga := 1.00;`).
   * Se `p_repeticoes < 1`, a procedure deve corrigir o valor na memória para `1` (`p_repeticoes := 1;`).
2. **Persistência dos dados (DML):**
   * Gere o próximo `ID_SERIE` sequencial (`SELECT NVL(MAX(ID_SERIE), 0) + 1 INTO v_novo_id FROM TRE_SERIE;`).
   * Execute o comando `INSERT INTO TRE_SERIE (ID_SERIE, ID_ITEM_TREINO, NUM_SERIE, CARGA, REPETICOES)` inserindo os valores com os parâmetros ajustados.
3. **Retorno do Status no `OUT`:**
   * Se a inserção foi concluída com sucesso (`SQL%ROWCOUNT = 1`), atribua:  
     `p_status_gravacao := 'SERIE REGISTRADA COM SUCESSO (ID: ' || v_novo_id || ')';`
   * Caso contrário, atribua `'FALHA AO REGISTRAR'`.
4. **Bloco Anônimo de Teste:**
   * Escreva um bloco anônimo passando uma carga negativa (ex: `-5`) e repetições zero (`0`), comprovando que a procedure corrigiu os parâmetros e exibindo o status com `DBMS_OUTPUT.PUT_LINE`.

**Exigências:**
* Uso correto dos 3 modos de parâmetros (`IN`, `OUT`, `IN OUT`).
* Usar `SQL%ROWCOUNT`.
* Sem bloco `EXCEPTION`.
* Fornecer o bloco anônimo de teste completo.

💡 **Dica de Raciocínio:** O `IN OUT` altera diretamente a variável de quem chamou. O `INSERT` grava os valores já saneados, e o parâmetro `OUT` devolve a mensagem formatada para o terminal.

---

### 🎯 EXERCÍCIO 4 (Modularização: Procedure Consumindo Function)
Crie uma procedure chamada **`PRC_ATUALIZAR_RECORDES_USUARIO`** que receba:
* `p_id_usuario IN NUMBER`

**Regras de Negócio da Procedure:**
1. A procedure deve rodar um `UPDATE` na tabela `TRE_RECORD` para atualizar os recordes do usuário informado (`p_id_usuario`).
2. **Reuso de Código (Padrão de Prova):** Em vez de reescrever queries complexas e repetidas de séries dentro do comando, **chame diretamente a função que você criou no Exercício 1** (`FNC_MAIOR_CARGA_USUARIO(p_id_usuario, r.ID_EXERCICIO)`) para obter a nova carga e também para verificar na cláusula `WHERE` se a carga calculada pela função é estritamente maior que `r.CARGA_RECORD`.
3. Ao atualizar a carga com o retorno da função, atualize também a data do recorde para `DATA_RECORD = TRUNC(SYSDATE)`.
4. Ao final, imprima com `DBMS_OUTPUT.PUT_LINE` a quantidade de recordes superados e atualizados usando `SQL%ROWCOUNT`.

**Exigências:**
* Usar comando `UPDATE` na tabela `TRE_RECORD`.
* Chamar obrigatoriamente a função `FNC_MAIOR_CARGA_USUARIO` dentro do `UPDATE` (no `SET` e no `WHERE`).
* Usar `SQL%ROWCOUNT` e `DBMS_OUTPUT.PUT_LINE`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O comando fica extremamente limpo: `UPDATE TRE_RECORD r SET r.CARGA_RECORD = FNC_MAIOR_CARGA_USUARIO(p_id_usuario, r.ID_EXERCICIO), r.DATA_RECORD = TRUNC(SYSDATE) WHERE r.ID_USUARIO = p_id_usuario AND FNC_MAIOR_CARGA_USUARIO(p_id_usuario, r.ID_EXERCICIO) > r.CARGA_RECORD;`. Em seguida, exiba o `SQL%ROWCOUNT`.

