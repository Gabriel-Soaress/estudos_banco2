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

### 1.6 O Casamento entre Meta e Recorde (A Linha do Tempo da Vigência)

> 🎟️ **A Analogia do Ingresso de Academia:**  
> Imagine que você comprou um plano trimestral na academia válido de **01/01 a 31/03**.  
> Qualquer treino, recorde ou evolução que você conquistar nesse período pertence a esse plano específico. Se você bater um recorde no dia 15/04, ele já pertence ao plano seguinte!

No banco de dados, a tabela `TRE_META` não tem uma chave estrangeira direta para cada linha de `TRE_RECORD`. **Eles se conectam pela Linha do Tempo (Vigência Temporal)**:
* **Usuário e Exercício em Comum:** `r.ID_USUARIO = m.ID_USUARIO AND r.ID_EXERCICIO = m.ID_EXERCICIO`
* **Vigência da Meta:** O recorde foi batido dentro do período da meta:  
  `r.DATA_RECORD BETWEEN m.DATA_CRIACAO AND NVL(m.DATA_CONCLUSAO, m.DATA_ALVO)`
* **Vínculo com a Série Real:** E como descobrir em qual série exata aquele recorde foi gerado?  
  Ligando a data do recorde com a data do treino (`TRUNC(t.DATA_TREINO) = TRUNC(r.DATA_RECORD)`), no exercício correspondente (`it.ID_EXERCICIO = r.ID_EXERCICIO`), achando a série exata onde `s.CARGA = r.CARGA_RECORD`!

---

### 1.7 O Super Poder do `%ROWTYPE` (A Maleta de Ferramentas Completa)

Você já usou `%TYPE` nos dias anteriores (`v_nome tre_usuario.nome%TYPE`). Agora é hora de subir de nível com o **`%ROWTYPE`**.

#### 🧰 A Analogia do Cotidiano:
* **`%TYPE` (A Chave Avulsa):** Você vai na loja e compra uma única chave de fenda de 10mm para mexer em um parafuso específico. Ele copia o tipo de **uma única coluna** da tabela.
* **`%ROWTYPE` (A Maleta Completa de Ferramentas):** Você compra a maleta oficial da montadora. Dentro dela já vem **todas as ferramentas encaixadas** em seus devidos lugares! Ele cria uma variável especial (chamada de *Record*) que espelha **uma linha inteira da tabela de uma só vez**!

---

#### 🆚 Comparativo Prático: Como você fazia vs Como você pode fazer agora

##### ❌ O Jeito Trabalhoso (Declarando variável por variável):
Para buscar os dados de uma meta, você tinha que declarar uma por uma:
```sql
DECLARE
    v_id_usuario    NUMBER;
    v_id_exercicio  NUMBER;
    v_carga_alvo    NUMBER(6,2);
    v_data_criacao  DATE;
    v_data_alvo     DATE;
BEGIN
    SELECT ID_USUARIO, ID_EXERCICIO, CARGA_ALVO, DATA_CRIACAO, DATA_ALVO
    INTO v_id_usuario, v_id_exercicio, v_carga_alvo, v_data_criacao, v_data_alvo
    FROM TRE_META
    WHERE ID_META = 1;
END;
```

##### ✅ O Jeito Elegante com `%ROWTYPE`:
Você declara **apenas uma única variável** para a linha inteira:
```sql
DECLARE
    v_meta TRE_META%ROWTYPE; -- Cria a maleta completa com todas as colunas de TRE_META!
BEGIN
    -- O SELECT * joga a linha inteira para dentro da maleta de uma vez só:
    SELECT *
    INTO v_meta
    FROM TRE_META
    WHERE ID_META = 1;

    -- Para acessar qualquer campo, basta usar "ponto" (v_meta.NOME_DA_COLUNA):
    DBMS_OUTPUT.PUT_LINE('Usuario: '    || v_meta.ID_USUARIO);
    DBMS_OUTPUT.PUT_LINE('Exercicio: '  || v_meta.ID_EXERCICIO);
    DBMS_OUTPUT.PUT_LINE('Carga Alvo: ' || v_meta.CARGA_ALVO);
    DBMS_OUTPUT.PUT_LINE('Criado em: '  || v_meta.DATA_CRIACAO);
END;
/
```

> 💡 **Vantagens de Ouro para a Prova:**
> 1. **Economiza dezenas de linhas de código:** Você não perde tempo digitando lista imensa de variáveis no `DECLARE` e nem no `INTO`.
> 2. **Imune a mudanças de tipo:** Se o professor alterar o tipo de qualquer coluna da tabela, o seu código continua funcionando perfeitamente sem precisar mudar nenhuma declaração!
> 3. **Perfeito para Functions e Procedures:** Quando você precisa consultar os dados cadastrais de uma meta ou usuário para tomar decisões com `IF/ELSE`, o `%ROWTYPE` deixa seu código extremamente limpo.

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
   * Gere o código da série sequencial formatado: `'SER-' || LPAD(v_novo_id, 3, '0')`.
   * Execute o comando `INSERT INTO TRE_SERIE (ID_SERIE, ID_ITEM_TREINO, COD_SERIE, NUMERO_SERIE, CARGA, REPETICOES)` inserindo os valores com os parâmetros ajustados.
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

---

### 🎯 EXERCÍCIO 5 (Conexão Temporal: Recordes na Vigência da Meta)
Crie uma função chamada **`FNC_RECORDES_NA_VIGENCIA_META`** que receba:
* `p_id_meta IN NUMBER`

**Regras de Negócio da Função:**
1. A função deve retornar um `NUMBER`.
2. Ela deve buscar na tabela `TRE_META` os seguintes dados da meta recebida:
   * `ID_USUARIO`
   * `ID_EXERCICIO`
   * `DATA_CRIACAO`
   * `DATA_CONCLUSAO`
   * `DATA_ALVO`
3. A vigência da meta se encerra na data em que ela foi concluída (`DATA_CONCLUSAO`). Se ela ainda não foi concluída (`DATA_CONCLUSAO IS NULL`), a vigência vai até a sua data limite estipulada (`DATA_ALVO`). Dica: use `NVL(DATA_CONCLUSAO, DATA_ALVO)`.
4. Conte quantos recordes foram registrados na tabela `TRE_RECORD` para esse mesmo usuário e exercício cuja `DATA_RECORD` esteja dentro do período:  
   `DATA_RECORD BETWEEN DATA_CRIACAO AND NVL(DATA_CONCLUSAO, DATA_ALVO)`
5. Retorne a quantidade total de recordes encontrados (ou `0` se nenhum).
6. **Chamada obrigatória no `SELECT`:**
   Escreva uma consulta na tabela `TRE_META` exibindo:
   * `COD_META`
   * `CARGA_ALVO`
   * `STATUS`
   * A chamada da função **`FNC_RECORDES_NA_VIGENCIA_META(ID_META)`** com o alias `TOTAL_RECORDES_VIGENCIA`.

**Exigências:**
* Usar `CREATE OR REPLACE FUNCTION`.
* Retornar `NUMBER`.
* Lógica temporal com `BETWEEN` e `NVL`.
* Sem bloco `EXCEPTION`.
* Apresentar o comando `SELECT` consumindo a função.

💡 **Dica de Raciocínio:** Busque os dados da meta em variáveis locais (`v_id_usuario, v_id_exercicio, v_dt_inicio, v_dt_fim`). Em seguida, faça um `SELECT COUNT(*) INTO v_qtd FROM TRE_RECORD WHERE ID_USUARIO = v_id_usuario AND ID_EXERCICIO = v_id_exercicio AND DATA_RECORD BETWEEN v_dt_inicio AND v_dt_fim;`. Retorne `v_qtd`.


