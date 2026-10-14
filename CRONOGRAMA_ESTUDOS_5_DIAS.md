# 📅 CRONOGRAMA DE GUERRA: BANCO DE DADOS II (5 DIAS)

> **Dedicação diária:** 1h30 a 2h  
> **SGBD:** Oracle SQL & PL/SQL  
> **Banco de Dados Oficial:** Sistema de Treinos e Metas (`TRE_`)

---

## 🗺️ Visão Geral da Distribuição de Conteúdos

Para não sobrecarregar nenhum dia e garantir que você fixe com profundidade prática, os temas foram distribuídos onde eles naturalmente se conectam:

```
[DIA 1] JOINs sem Produto Cartesiano + Subqueries no SELECT / FROM + Funções de Nulos (NVL, COALESCE)
   │
[DIA 2] GROUP BY + Agregações Avançadas + Extremos (Maior/Menor) + Funções Numéricas (ROUND, TRUNC, NULLIF)
   │
[DIA 3] Subqueries Aninhadas em DML (INSERT, UPDATE, DELETE) + DDL + Funções de Data/Texto (TO_CHAR, UPPER)
   │
[DIA 4] VIEWS Analíticas + Classificações Complexas (CASE WHEN, NVL2) + Relatórios Consolidados
   │
[DIA 5] PL/SQL: Functions + Procedures (IN, OUT, IN OUT) sem Exception + Simulado Completo de Prova
```

---

## 📋 Detalhamento Dia a Dia

---

### 🔹 DIA 1: Anti-Produto Cartesiano & Subqueries Aninhadas no SELECT e FROM
* **Carga Horária:** ~1h45
* **Foco Teórico:**
  * Por que ocorre o Produto Cartesiano (Fan-out) ao cruzar tabelas 1:N no mesmo nível (`TRE_SERIE`, `TRE_RECORD`, `TRE_META`).
  * Subqueries escalares no `SELECT` (regras, limitações de 1 linha/1 coluna e uso da tabela `DUAL`).
  * Tabelas derivadas (subqueries aninhadas no `FROM`) para pré-agrupar dados antes do cruzamento.
* **Funções Auxiliares do Dia:**
  * `NVL(campo, valor_padrao)` – tratamento padrão de nulos em `LEFT JOIN`.
  * `COALESCE(v1, v2, ...)` – primeiro valor não-nulo da lista.
  * `UPPER()` / `LOWER()` – tratamento de strings para filtros com `LIKE`.
* **Prática no Banco `TRE_`:**
  * **Questão 1 do Professor adaptada:** Contar usuários e exercícios com inicial específica em uma linha usando subqueries aninhadas no `SELECT` com `DUAL`.
  * Relacionar usuários, metas ativas e maior carga de séries sem duplicar linhas usando subqueries no `FROM`.

---

### 🔹 DIA 2: GROUP BY, Agregações Avançadas & Questões de Extremos
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * Regras obrigatórias do `GROUP BY` e a diferença de filtragem: `WHERE` (pré-agrupamento) vs `HAVING` (pós-agrupamento).
  * Agregações: `COUNT`, `SUM`, `AVG`, `MAX`, `MIN`.
  * Subqueries no `HAVING` e no `WHERE` para capturar os "donos" do maior e menor valor.
  * Subqueries correlacionadas.
* **Funções Auxiliares do Dia:**
  * `ROUND(valor, decimais)` – arredondamento matemático para médias.
  * `TRUNC(valor, decimais)` – truncamento de valores numéricos.
  * `NULLIF(v1, v2)` – proteção contra o erro fatal de divisão por zero (`ORA-01476`).
* **Prática no Banco `TRE_`:**
  * **Questão 2 do Professor adaptada:** Usuário com a maior média de carga e o exercício com o maior recorde absoluto do sistema.
  * **Questão 4 do Professor adaptada:** Para cada grupo muscular, identificar o exercício com a maior e a menor carga máxima registrada.

---

### 🔹 DIA 3: Subqueries Aninhadas em DML (INSERT, UPDATE, DELETE) & DDL
* **Carga Horária:** ~1h45
* **Foco Teórico:**
  * `ALTER TABLE ... ADD` para criar novas colunas de controle.
  * `UPDATE` com subquery no `SET` e no `WHERE` (`UPDATE ... SET col = (SELECT ...)`).
  * `INSERT INTO ... SELECT` para povoar dados históricos a partir de séries já executadas.
  * `DELETE` com subqueries (`IN`, `NOT IN`, `EXISTS`).
* **Funções Auxiliares do Dia:**
  * `TO_CHAR(data, formato)` – conversão e formatação de datas em relatórios e filtros.
  * `TO_DATE(texto, formato)` – conversão explícita de strings para datas em comandos DML.
  * `SYSDATE` – captura da data e hora atual do servidor Oracle.
* **Prática no Banco `TRE_`:**
  * **Questão 3 do Professor adaptada:** Adicionar coluna `CATEGORIA` em `TRE_USUARIO`, rodar `UPDATE` com subquery aninhada para marcar `'AVANÇADO'` quem tem recordes $\ge 100$ kg e consultar os totais por categoria.
  * Inserir novos recordes automaticamente a partir do histórico de séries via `INSERT INTO ... SELECT`.
  * `DELETE` seguro de treinos que não possuem séries associadas.

---

### 🔹 DIA 4: VIEWS Analíticas & Relatórios Consolidados
* **Carga Horária:** ~1h30
* **Foco Teórico:**
  * O que é e para que serve uma View (`CREATE OR REPLACE VIEW`).
  * Vantagens em segurança, performance lógica e simplificação de código para o usuário final.
  * Como embutir múltiplos `JOIN`s, subqueries e agregações dentro de uma visão sem quebrar o banco.
* **Funções Auxiliares do Dia:**
  * `CASE WHEN ... THEN ... ELSE ... END` – criação de colunas computadas e rótulos analíticos dentro da View.
  * `NVL2(campo, se_preenchido, se_nulo)` – validação de campos opcionais.
* **Prática no Banco `TRE_`:**
  * Criar a view **`VW_DESEMPENHO_GERAL`**: consolida usuário, exercício, meta ativa, recorde histórico e maior carga levantada nas séries.
  * Criar a view **`VW_STATUS_METAS`**: classifica as metas do usuário em `'ATINGIDA'`, `'EM ANDAMENTO'` ou `'SEM TREINO REGISTRADO'`.

---

### 🔹 DIA 5: PL/SQL (Functions & Procedures) + Simulado de Prova
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * Estrutura básica de blocos PL/SQL (sem tratamento de `EXCEPTION`): variáveis, `BEGIN`, `END;`.
  * **Functions:** sintaxe, palavra-chave `RETURN`, chamadas válidas direto no comando `SELECT`.
  * **Procedures:** diferenças fundamentais de parâmetros:
    * **`IN`**: parâmetro somente leitura (comportamento de constante).
    * **`OUT`**: parâmetro de saída (retorna valor calculado para quem chamou).
    * **`IN OUT`**: parâmetro que entra com um valor, é alterado dentro da rotina e devolve o novo valor.
* **Prática no Banco `TRE_`:**
  * **Function:** recebe `ID_USUARIO` e `ID_EXERCICIO` e retorna a maior carga já executada em séries.
  * **Procedure:** procedure com `IN`, `OUT` e `IN OUT` para registrar uma série, validar a carga e retornar mensagem de status.
  * **Simulado Final de Prova:** 3 questões discursivas de código idênticas às que o professor cobrará.

---

## 🎯 Quadro de Progresso

| Dia | Tema Central | Status |
| :---: | :--- | :---: |
| **1** | Anti-Produto Cartesiano, Subqueries no SELECT/FROM, NVL, COALESCE | ✅ Concluído |
| **2** | GROUP BY, HAVING, Extremos (Q2, Q4), ROUND, NULLIF | ⏳ Próximo |
| **3** | Subqueries em DML (INSERT, UPDATE, DELETE), DDL (Q3), TO_CHAR | ⬜ A fazer |
| **4** | VIEWS Analíticas, CASE WHEN, Relatórios Consolidados | ⬜ A fazer |
| **5** | PL/SQL (Functions, Procedures IN/OUT/IN OUT) + Simulado | ⬜ A fazer |

