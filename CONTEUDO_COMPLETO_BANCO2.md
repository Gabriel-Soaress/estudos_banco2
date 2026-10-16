# 📘 MANUAL COMPLETO DE TEORIA E FUNDAMENTOS: BANCO DE DADOS II
### Preparação Definitiva para a Prova (Oracle SQL & PL/SQL)

---

## 🧭 SUMÁRIO GERAL DO CONTEÚDO
1. [Módulo 1: Consultas Avançadas & Prevenção do Produto Cartesiano](#módulo-1-consultas-avançadas--prevenção-do-produto-cartesiano)
2. [Módulo 2: Agregações, Extremos & Views Analíticas](#módulo-2-agregações-extremos--views-analíticas)
3. [Módulo 3: Encapsulamento DML & Procedures PL/SQL](#módulo-3-encapsulamento-dml--procedures-plsql)
4. [Módulo 4: Functions no SELECT, Parâmetros e %ROWTYPE](#módulo-4-functions-no-select-parâmetros-e-rowtype)

---

# MÓDULO 1: CONSULTAS AVANÇADAS & PREVENÇÃO DO PRODUTO CARTESIANO

## 1.1 O que é o Produto Cartesiano e Como Evitá-lo
O produto cartesiano ocorre quando o banco cruza todas as linhas de uma tabela com todas as linhas de outra sem critério, gerando multiplicações absurdas de dados.

* **A Analogia das Fichas de Treino:**  
  Imagine um aluno que tem 3 treinos cadastrados e 4 metas. Se você fizer um `JOIN` simples entre Treino e Meta no mesmo nível, o banco não sabe quem se liga com quem e gera $3 \times 4 = 12$ linhas! Valores numéricos somados triplicam ou quadruplicam artificialmente.
* **A Regra de Ouro Anti-Cartesiano:**  
  Nunca faça `JOIN` entre duas tabelas filhas (relações 1:N) no mesmo nível da consulta principal. Em vez disso, isole o cálculo de uma delas usando **Subqueries no SELECT** ou **Subqueries no FROM (Inline Views)**.

---

## 1.2 Subqueries no SELECT (Subqueries Escalares)
Uma subquery no `SELECT` deve devolver **estritamente um único valor** (uma linha e uma coluna), comportando-se exatamente como uma célula do Excel.

* **A Tabela `DUAL` do Oracle:**  
  É uma tabela especial de uma linha e uma coluna mantida pelo Oracle para testar cálculos ou unir subqueries escalares:
  ```sql
  SELECT 
      (SELECT COUNT(*) FROM TRE_TREINO WHERE ID_USUARIO = 1) AS TOTAL_TREINOS,
      (SELECT COUNT(*) FROM TRE_META WHERE ID_USUARIO = 1) AS TOTAL_METAS
  FROM DUAL;
  ```

---

## 1.3 Subqueries no FROM (Tabelas Derivadas / Inline Views)
Como o professor **proibiu o uso de `WITH` (CTEs)**, qualquer agregação prévia antes de um join deve ser feita através de subqueries entre parênteses dentro da cláusula `FROM`:

```sql
SELECT 
    u.NOME,
    totais.QTD_TREINOS
FROM TRE_USUARIO u
LEFT JOIN (
    SELECT ID_USUARIO, COUNT(*) AS QTD_TREINOS
    FROM TRE_TREINO
    GROUP BY ID_USUARIO
) totais ON totais.ID_USUARIO = u.ID_USUARIO;
```
> O banco de dados primeiro processa a tabela virtual temporária `totais` e só depois junta com os usuários, garantindo que nenhuma linha seja multiplicada.

---

## 1.4 Tratamento de Nulos: `NVL` vs `COALESCE`
* **`NVL(valor, substituto)`:** Nativo do Oracle. Recebe 2 parâmetros. Se o primeiro for nulo, devolve o segundo.  
  *Exemplo:* `NVL(s.CARGA, 0)` $\rightarrow$ se a carga for nula, assume 0.
* **`COALESCE(v1, v2, v3, ...)`:** Padrão ANSI. Avalia uma lista da esquerda para a direita e devolve o primeiro valor não-nulo encontrado.

---

# MÓDULO 2: AGREGAÇÕES, EXTREMOS & VIEWS ANALÍTICAS

## 2.1 A Regra de Ouro do `GROUP BY`
* **A Analogia da Caixa de Papelão Lacrada:**  
  Pense no `GROUP BY` como fechar as linhas dentro de caixas de papelão. Se você agrupar por `ID_USUARIO`, você colocou todas as 50 séries daquele aluno dentro de uma única caixa e lacrou com fita adesiva.  
  O Oracle só consegue ver o que você escreveu **do lado de fora da caixa** (as colunas do `GROUP BY`) ou etiquetas de resumo calculadas na tampa (`COUNT`, `MAX`, `MIN`, `AVG`, `SUM`).  
  *Regra:* Toda coluna no `SELECT` que não tiver função agregadora **tem que estar obrigatoriamente listada no `GROUP BY`**!

---

## 2.2 `WHERE` vs `HAVING`
* **`WHERE` (O Porteiro da Fábrica):**  
  Filtra linhas individuais **antes** de entrarem na caixa do `GROUP BY`. Não pode conter funções agregadas (`WHERE CARGA > 50`).
* **`HAVING` (O Controle de Qualidade):**  
  Filtra caixas inteiras **depois** que o grupo já foi consolidado. Avalia o resultado das agregações (`HAVING MAX(CARGA) >= 100` ou `HAVING COUNT(*) > 5`).

---

## 2.3 Como Descobrir o Dono do Maior ou Menor Valor
Funções como `MAX()` ou `MIN()` apenas mostram o número recorde (ex: `150kg`), mas não trazem o nome de quem levantou. Para pescar o dono do recorde sem violar o `GROUP BY`:

```sql
SELECT u.NOME, r.CARGA_RECORD
FROM TRE_RECORD r
JOIN TRE_USUARIO u ON u.ID_USUARIO = r.ID_USUARIO
WHERE r.CARGA_RECORD = (
    -- Subquery no WHERE que descobre o maior valor absoluto
    SELECT MAX(CARGA_RECORD) FROM TRE_RECORD
);
```

---

## 2.4 Funções Numéricas e Proteção contra Divisão por Zero
* **`ROUND(numero, casas)`:** Arredonda matematicamente (`ROUND(12.345, 2)` $\rightarrow$ `12.35`).
* **`TRUNC(numero, casas)`:** Corta os decimais sem arredondar. Com datas, remove horas, minutos e segundos (`TRUNC(SYSDATE)`).
* **`NULLIF(a, b)`:** Devolve `NULL` se `a = b`. É a proteção ideal contra erro de divisão por zero:  
  `VALOR_TOTAL / NULLIF(QUANTIDADE, 0)` $\rightarrow$ se a quantidade for 0, o divisor vira nulo e a divisão resulta em `NULL`, sem travar a consulta com erro do Oracle.

---

## 2.5 VIEWS Analíticas
* **A Analogia do Caderno de Receitas:**  
  Uma View não guarda cópia física dos dados. Ela guarda uma **fórmula salva**. Toda vez que alguém consulta a View, o Oracle abre o caderno e executa a receita em tempo real.
* **Sintaxe Oficial:**
  ```sql
  CREATE OR REPLACE VIEW VW_DESEMPENHO_USUARIOS AS
  SELECT 
      u.COD_USUARIO,
      u.NOME,
      COUNT(t.ID_TREINO) AS TOTAL_TREINOS,
      NVL(MAX(t.DURACAO_MINUTO), 0) AS MAIOR_DURACAO
  FROM TRE_USUARIO u
  LEFT JOIN TRE_TREINO t ON t.ID_USUARIO = u.ID_USUARIO
  GROUP BY u.COD_USUARIO, u.NOME;
  ```

---

# MÓDULO 3: ENCAPSULAMENTO DML & PROCEDURES PL/SQL

## 3.1 O que é uma PROCEDURE
Uma Procedure é um bloco de comandos PL/SQL armazenado no banco que executa processos em lote, tarefas administrativas e comandos de escrita (`INSERT`, `UPDATE`, `DELETE`).

---

## 3.2 Modos de Parâmetros: `IN`, `OUT` e `IN OUT`
* **`IN` (Somente Leitura):** O valor entra na procedure. Ela pode ler e usar em filtros, mas nunca alterar. É o modo padrão se você não especificar nada.
* **`OUT` (Somente Escrita / Retorno):** A variável entra vazia. A procedure calcula e atribui um valor a ela para devolver a quem chamou.
* **`IN OUT` (Leitura e Escrita):** A variável entra com um valor existente, a procedure lê, sanitiza/modifica o valor e devolve atualizado na mesma variável.

---

## 3.3 Comandos DML com Subqueries Aninhadas

### 1. `UPDATE` com Subquery no `WHERE`:
```sql
UPDATE TRE_USUARIO
SET CATEGORIA = 'AVANÇADO'
WHERE ID_USUARIO IN (
    SELECT DISTINCT ID_USUARIO 
    FROM TRE_RECORD 
    WHERE CARGA_RECORD >= 100
);
```

### 2. `INSERT INTO ... SELECT`:
Insere o lote gerado por uma consulta diretamente na tabela de destino sem precisar do comando `VALUES`:
```sql
INSERT INTO TRE_RECORD (ID_USUARIO, ID_EXERCICIO, COD_RECORD, CARGA_RECORD, DATA_RECORD)
SELECT 
    t.ID_USUARIO,
    it.ID_EXERCICIO,
    'REC-' || LPAD(ROWNUM, 3, '0'),
    MAX(s.CARGA),
    TRUNC(SYSDATE)
FROM TRE_TREINO t
JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
GROUP BY t.ID_USUARIO, it.ID_EXERCICIO;
```

### 3. `DELETE` Seguro com `NOT IN`:
Remove registros órfãos que não possuem filhos associados:
```sql
DELETE FROM TRE_TREINO
WHERE ID_TREINO NOT IN (
    SELECT ID_TREINO 
    FROM TRE_ITEM_TREINO 
    WHERE ID_TREINO IS NOT NULL -- Proteção indispensável contra nulos!
);
```

---

## 3.4 O Contador Oculto: `SQL%ROWCOUNT`
Sempre que o Oracle executa qualquer comando DML (`INSERT`, `UPDATE`, `DELETE`), ele atualiza automaticamente a variável de sistema `SQL%ROWCOUNT` com a **quantidade exata de linhas afetadas**:
```sql
DELETE FROM TRE_TREINO WHERE ...;
DBMS_OUTPUT.PUT_LINE('Treinos removidos: ' || SQL%ROWCOUNT);
```

---

# MÓDULO 4: FUNCTIONS NO SELECT, PARÂMETROS E %ROWTYPE

## 4.1 PROCEDURE vs FUNCTION: A Diferença de Ouro

| Recurso | A Analogia | Retorno Obrigatório | Pode ser chamada no `SELECT`? | Propósito |
| :--- | :--- | :---: | :---: | :--- |
| **`PROCEDURE`** | O Mecânico da Oficina | Não | ❌ **NUNCA** | Executar tarefas, DML e processos complexos. |
| **`FUNCTION`** | O Caixa Eletrônico | `RETURN <tipo>` no cabeçalho e `RETURN <valor>` no corpo | ✅ **SIM!** | Calcular/transformar um dado e cuspir um valor único de volta. |

---

## 4.2 Anatomia e Uso de FUNCTIONS
Uma função para ser usada em consultas `SELECT` deve ser estritamente voltada para cálculos e leitura.

* **Regra Inegociável:** Functions chamadas no `SELECT` **jamais podem executar `INSERT`, `UPDATE` ou `DELETE`** (`ORA-14551: cannot perform a DML operation inside a query`).
* **Estrutura Básica:**
  ```sql
  CREATE OR REPLACE FUNCTION FNC_MAIOR_CARGA (
      p_id_usuario IN NUMBER,
      p_id_exercicio IN NUMBER
  ) RETURN NUMBER
  IS
      v_maior NUMBER := 0;
  BEGIN
      SELECT NVL(MAX(s.CARGA), 0)
      INTO v_maior
      FROM TRE_TREINO t
      JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
      JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
      WHERE t.ID_USUARIO = p_id_usuario
        AND it.ID_EXERCICIO = p_id_exercicio;

      RETURN v_maior;
  END;
  /
  ```
* **Chamada no `SELECT` (Como fórmula de planilha):**
  ```sql
  SELECT NOME, FNC_MAIOR_CARGA(ID_USUARIO, 1) AS CARGA_SUPINO
  FROM TRE_USUARIO;
  ```

---

## 4.3 O Super Poder do `%ROWTYPE`
* **`%TYPE`:** Copia o tipo de uma única coluna (`v_nome tre_usuario.nome%TYPE`).
* **`%ROWTYPE` (A Maleta Completa):** Cria uma variável do tipo registro que espelha **uma linha inteira de uma tabela de uma só vez**:
  ```sql
  DECLARE
      v_meta TRE_META%ROWTYPE;
  BEGIN
      SELECT *
      INTO v_meta
      FROM TRE_META
      WHERE ID_META = 1;

      -- Acessa qualquer coluna através de notação com ponto (.):
      DBMS_OUTPUT.PUT_LINE('Alvo: ' || v_meta.CARGA_ALVO || ' | Status: ' || v_meta.STATUS);
  END;
  /
  ```

---

## 4.4 Modularização: Procedures Consumindo Functions
Em vez de repetir joins e cálculos gigantescos dentro de um comando `UPDATE`, uma procedure pode invocar uma Function diretamente em sua cláusula `SET` e `WHERE`:

```sql
CREATE OR REPLACE PROCEDURE PRC_ATUALIZAR_RECORDES (
    p_id_usuario IN NUMBER
) IS
BEGIN
    UPDATE TRE_RECORD r
    SET CARGA_RECORD = FNC_MAIOR_CARGA(p_id_usuario, r.ID_EXERCICIO),
        DATA_RECORD  = TRUNC(SYSDATE)
    WHERE r.ID_USUARIO = p_id_usuario
      AND FNC_MAIOR_CARGA(p_id_usuario, r.ID_EXERCICIO) > r.CARGA_RECORD;

    DBMS_OUTPUT.PUT_LINE('Total atualizado: ' || SQL%ROWCOUNT);
END;
/
```
