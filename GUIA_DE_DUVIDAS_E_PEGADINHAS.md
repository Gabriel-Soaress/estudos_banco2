# 🚨 GUIA DEFINITIVO DE DÚVIDAS, PEGADINHAS E ERROS DE PROVA (BANCO DE DADOS II)
> Este documento reúne todas as dúvidas reais, tropeços e sacadas que surgiram ao longo do seu treinamento prático, explicadas de forma didática com analogias e soluções diretas.

---

## 🧭 ÍNDICE DE SOBREVIVÊNCIA

1. [A Cadeira Única do `SELECT ... INTO` e Empates (Erro `ORA-01422`)](#1-a-cadeira-única-do-select--into-e-empates-erro-ora-01422)
2. [Por que Parâmetros `OUT` e `IN OUT` DEVEM ser Variáveis de Memória (Erro `PLS-00363`)](#2-por-que-parâmetros-out-e-in-out-devem-ser-variáveis-de-memória-erro-pls-00363)
3. [Como fazer `UPDATE` Multinível sem `WITH` (A Analogia das Gavetas)](#3-como-fazer-update-multinível-sem-with-a-analogia-das-gavetas)
4. [O `NULL` Traiçoeiro dentro do `NOT IN` (A Consulta que Devolve Vazio)](#4-o-null-traiçoeiro-dentro-do-not-in-a-consulta-que-devolve-vazio)
5. [A Variável Fantasma no `SELECT ... INTO`](#5-a-variável-fantasma-no-select--into)
6. [O Cadeado da Tabela no DDL (Erro `ORA-00054 NOWAIT`)](#6-o-cadeado-da-tabela-no-ddl-erro-ora-00054-nowait)
7. [Por que Functions com Parâmetro `OUT` NÃO Podem Entrar no `SELECT` (Erro `ORA-06572`)](#7-por-que-functions-com-parâmetro-out-não-podem-entrar-no-select-erro-ora-06572)
8. [O `%ROWTYPE` sem o Asterisco `*` (A Caixa de Ovos e o Erro `PLS-00386`)](#8-o-rowtype-sem-o-asterisco--a-caixa-de-ovos-e-o-erro-pls-00386)
9. [O Perigo Mortal do `CASE` sem `ELSE` no PL/SQL (Erro `ORA-06592`)](#9-o-perigo-mortal-do-case-sem-else-no-plsql-erro-ora-06592)
10. [O Alias Proibido no Lado Esquerdo do `SET` no `UPDATE` (Erro `ORA-01747`)](#10-o-alias-proibido-no-lado-esquerdo-do-set-no-update-erro-ora-01747)
11. [A Esteira Rolante do `UPDATE`: Como o Oracle Passa `r.ID_EXERCICIO` Sozinho](#11-a-esteira-rolante-do-update-como-o-oracle-passa-rid_exercicio-sozinho)
12. [Cruzamento Temporal de Metas e Recordes sem Chave Estrangeira](#12-cruzamento-temporal-de-metas-e-recordes-sem-chave-estrangeira)

---

### 1. A Cadeira Única do `SELECT ... INTO` e Empates (Erro `ORA-01422`)

* **O Sintoma:** Você roda uma procedure e o Oracle cospe:  
  `ORA-01422: exact fetch returns more than requested number of rows`.
* **A Causa:** O `SELECT ... INTO` foi feito para acomodar **exatamente uma linha**. Se uma consulta buscar, por exemplo, o treino de maior duração (`WHERE DURACAO_MINUTO = v_maior`) e o aluno tiver **dois treinos de 60 minutos**, duas linhas tentam sentar na mesma cadeira ao mesmo tempo. A cadeira quebra!
* **A Solução na Prova:**
  * **Opção 1 (Mais recomendada):** Use uma função de grupo no campo que pode empatar:
    ```sql
    SELECT MAX(COD_TREINO) INTO v_cod FROM TRE_TREINO WHERE DURACAO_MINUTO = v_maior ...;
    ```
  * **Opção 2:** Force a parada na primeira ocorrência com `AND ROWNUM = 1`:
    ```sql
    SELECT COD_TREINO INTO v_cod FROM TRE_TREINO WHERE ... AND ROWNUM = 1;
    ```

---

### 2. Por que Parâmetros `OUT` e `IN OUT` DEVEM ser Variáveis de Memória (Erro `PLS-00363`)

* **O Sintoma:** Você tenta testar a procedure passando valores literais e recebe:  
  `PLS-00363: expression cannot be used as an assignment target`.
* **A Causa (A Analogia do Envelope vs Tijolo):**  
  * Um parâmetro `IN` é como mostrar uma foto na parede: a procedure só olha. Você pode passar números literais (`10`, `'AVANÇADO'`).
  * Já os parâmetros `OUT` e `IN OUT` são **envelopes de papel**: a procedure precisa escrever um resultado dentro deles e devolver para você. Você **não pode entregar uma parede de tijolo ou pedra sólida** (um valor fixo como `10` ou coluna direta de tabela) e mandar a procedure escrever dentro dela!
* **A Solução:** Crie sempre um bloco anônimo declarando variáveis antes de chamar:
  ```sql
  DECLARE
      v_carga NUMBER := -5;  -- Envelope com valor de entrada
      v_status VARCHAR2(100); -- Envelope vazio para o retorno
  BEGIN
      PRC_REGISTRAR_SERIE(1, 1, v_carga, v_status);
      DBMS_OUTPUT.PUT_LINE(v_status);
  END;
  /
  ```

---

### 3. Como fazer `UPDATE` Multinível sem `WITH` (A Analogia das Gavetas)

* **O Desafio:** Classificar usuários em níveis (até 50kg = Iniciante, até 80kg = Intermediário, $\ge$ 100kg = Avançado) sem usar CTEs (proibidas pelo professor).
* **A Analogia das Gavetas:** Pense na tabela `TRE_USUARIO` como uma ficha de alunos. Para cada aluno, o `UPDATE` abre uma gavetinha rápida no histórico (`TRE_RECORD`) e descobre a maior carga da vida dele.
* **A Solução:** Use o **`CASE WHEN` dentro do `UPDATE`** alimentado por uma subquery escalar:
  ```sql
  UPDATE TRE_USUARIO u
  SET u.CATEGORIA = CASE 
      WHEN (SELECT MAX(CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 100 THEN 'AVANÇADO'
      WHEN (SELECT MAX(CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 80  THEN 'INTERMEDIÁRIO'
      WHEN (SELECT MAX(CARGA_RECORD) FROM TRE_RECORD r WHERE r.ID_USUARIO = u.ID_USUARIO) >= 50  THEN 'INTERMEDIÁRIO'
      ELSE 'INICIANTE'
  END;
  ```

---

### 4. O `NULL` Traiçoeiro dentro do `NOT IN` (A Consulta que Devolve Vazio)

* **O Sintoma:** Você roda um `DELETE` ou `SELECT` com `WHERE ID NOT IN (SELECT ID FROM TABELA_FILHA)` e o banco devolve **zero linhas afetadas**, mesmo sabendo que existem registros órfãos!
* **A Causa:** Se a subquery interna trouxer **um único valor `NULL`**, a comparação lógica do `NOT IN` vira `UNKNOWN` para todas as linhas e o Oracle descarta a tabela inteira!
* **A Regra de Ouro:** **Sempre** coloque `WHERE coluna IS NOT NULL` dentro da subquery do `NOT IN`:
  ```sql
  DELETE FROM TRE_TREINO
  WHERE ID_TREINO NOT IN (
      SELECT ID_TREINO FROM TRE_ITEM_TREINO WHERE ID_TREINO IS NOT NULL
  );
  ```

---

### 5. A Variável Fantasma no `SELECT ... INTO`

* **O Sintoma:** Você declarou a variável `v_nome_usr`, mas quando o `DBMS_OUTPUT.PUT_LINE` roda, o nome aparece em branco (`NULL`).
* **A Causa:** O esquecimento no `INTO`:
  ```sql
  -- Errado: buscou o ID mas esqueceu o nome no INTO
  SELECT ID_USUARIO INTO v_id_usuario FROM TRE_USUARIO WHERE ...;
  ```
  O Oracle compila normalmente porque `v_nome_usr` existe, mas como nada foi colocado nela, ela continua com o valor padrão `NULL`.
* **A Solução:** Emparelhe cada coluna do `SELECT` com a sua respectiva variável no `INTO`:
  ```sql
  SELECT ID_USUARIO, NOME INTO v_id_usuario, v_nome_usr FROM TRE_USUARIO WHERE ...;
  ```

---

### 6. O Cadeado da Tabela no DDL (Erro `ORA-00054 NOWAIT`)

* **O Sintoma:** Você roda `ALTER TABLE TRE_USUARIO DROP COLUMN CATEGORIA` e o Oracle dá:  
  `ORA-00054: resource busy and acquire with NOWAIT specified`.
* **A Causa:** Qualquer `UPDATE`, `INSERT` ou `DELETE` anterior que não recebeu `COMMIT;` ou `ROLLBACK;` mantém um **cadeado exclusivo** na tabela. O `ALTER TABLE` exige silêncio absoluto no banco e se recusa a rodar se encontrar o menor cadeado.
* **A Solução:**
  1. Digite `COMMIT;` ou `ROLLBACK;` na aba que fez a alteração.
  2. Feche as abas visuais de "Dados" da tabela no SQL Developer (elas seguram bloqueios de visualização).
  3. Use o comando de espera do Oracle: `ALTER SESSION SET DDL_LOCK_TIMEOUT = 30;` antes do `ALTER TABLE`.

---

### 7. Por que Functions com Parâmetro `OUT` NÃO Podem Entrar no `SELECT` (Erro `ORA-06572`)

* **A Tentativa:** *"Vou criar uma function com parâmetro OUT pra ela me devolver a carga no RETURN e a data no OUT!"*
* **O Resultado:** Se você tentar chamar essa função dentro de um comando `SELECT`, o Oracle recusa na hora:  
  `ORA-06572: Function FNC_... has out arguments`.
* **A Razão:** O motor do SQL que desenha as linhas do `SELECT` na tela não possui variáveis PL/SQL alocadas em memória para segurar envelopes de saída de cada linha.
* **Regra de Ouro:** Funções para uso no `SELECT` **devem ser 100% puras**: apenas parâmetros de entrada (`IN`) e um único resultado no `RETURN`.

---

### 8. O `%ROWTYPE` sem o Asterisco `*` (A Caixa de Ovos e o Erro `PLS-00386`)

* **A Analogia da Caixa de Ovos:** Uma variável `TRE_META%ROWTYPE` é como uma caixa com **9 slots de ovos** moldada exatamente no formato da tabela `TRE_META`.
* **O Erro:** Fazer `SELECT ID_META, COD_META INTO v_meta`. Chegam 2 ovos para uma caixa de 9 slots. O Oracle se recusa a fechar a caixa (`PLS-00386: type mismatch`).
* **Como usar certo:**
  * **Opção Padrão:** `SELECT * INTO v_meta FROM TRE_META WHERE ...;` (enche todos os slots e você só lê os que quiser via `v_meta.NOME`).
  * **Opção Gaveta Específica:** `SELECT COD_META INTO v_meta.COD_META FROM ...;` (aponta para o slot exato).

---

### 9. O Perigo Mortal do `CASE` sem `ELSE` no PL/SQL (Erro `ORA-06592`)

* **A Pegadinha:**
  * No SQL tradicional (`SELECT CASE WHEN ... END`), se nenhuma condição for atendida, o banco apenas devolve `NULL` silenciosamente.
  * Mas no **PL/SQL procedural** (`CASE WHEN ... END CASE;`), se nenhum `WHEN` for verdadeiro e você **não tiver colocado a cláusula `ELSE`**, o Oracle estoura o erro fatal:  
    `ORA-06592: CASE not found while executing CASE statement`.
* **A Solução:** Sempre inclua um caminho de segurança no final do `CASE`:
  ```sql
  CASE 
      WHEN v_pct >= 100 THEN v_msg := 'CONCLUIDA';
      WHEN v_pct >= 80  THEN v_msg := 'QUASE LA';
      ELSE v_msg := 'EM PROGRESSO'; -- OBRIGATÓRIO!
  END CASE;
  ```

---

### 10. O Alias Proibido no Lado Esquerdo do `SET` no `UPDATE` (Erro `ORA-01747`)

* **O Erro Clássico:**
  ```sql
  -- ❌ ERRO! ORA-01747: invalid user.table.column specification
  UPDATE TRE_RECORD r
  SET r.CARGA_RECORD = 120.00
  WHERE r.ID_USUARIO = 1;
  ```
* **A Causa:** A gramática do Oracle proíbe estritamente qualificar o nome da coluna que está sendo atualizada com o alias da tabela no lado esquerdo do sinal de igual (`=`).
* **O Certo:**
  ```sql
  -- ✅ CERTO: Coluna sem alias na esquerda, alias permitido na direita e no WHERE
  UPDATE TRE_RECORD r
  SET CARGA_RECORD = FNC_MAIOR_CARGA(p_id, r.ID_EXERCICIO)
  WHERE r.ID_USUARIO = 1;
  ```

---

### 11. A Esteira Rolante do `UPDATE`: Como o Oracle Passa `r.ID_EXERCICIO` Sozinho

* **A Dúvida:** *"Como que o Oracle soube qual exercício mandar para a função sem eu ter feito nenhum loop `FOR`?"*
* **A Analogia da Esteira de Fábrica:**  
  O comando `UPDATE` coloca todas as linhas filtradas em uma esteira rolante.  
  Quando a primeira caixa passa na esteira, ela é o Supino (`r.ID_EXERCICIO = 1`). O Oracle lê o número da caixa e entrega na hora para a função `FNC_MAIOR_CARGA(p_id, 1)`.  
  Quando passa a segunda caixa, é o Agachamento (`r.ID_EXERCICIO = 2`). O Oracle lê e entrega `FNC_MAIOR_CARGA(p_id, 2)`.  
  O SQL é orientado a conjuntos: o apelido `r.` enxerga a linha corrente automaticamente!
* **E por que o `DBMS_OUTPUT` às vezes não sai?**
  1. O terminal está com `SET SERVEROUTPUT ON;` desligado.
  2. Nenhuma linha satisfez a condição do `WHERE` (ex: nenhum recorde foi superado), fazendo o `SQL%ROWCOUNT` ser 0.

---

### 12. Cruzamento Temporal de Metas e Recordes sem Chave Estrangeira

* **O Desafio:** Como associar uma linha de `TRE_RECORD` a uma `TRE_META` se não existe a coluna `ID_META` na tabela de recordes?
* **A Resposta (A Linha do Tempo da Vigência):**
  Eles se amarram por **3 critérios lógicos**:
  1. Mesmo usuário: `r.ID_USUARIO = m.ID_USUARIO`
  2. Mesmo exercício: `r.ID_EXERCICIO = m.ID_EXERCICIO`
  3. Data do recorde dentro da validade da meta:  
     `r.DATA_RECORD BETWEEN m.DATA_CRIACAO AND NVL(m.DATA_CONCLUSAO, SYSDATE)`
