# 📅 CRONOGRAMA DE GUERRA: BANCO DE DADOS II (5 DIAS - REESTRUTURADO)

> **Dedicação diária:** 1h30 a 2h  
> **SGBD:** Oracle SQL & PL/SQL  
> **Banco de Dados Oficial:** Sistema de Treinos e Metas (`TRE_`)

---

## 🗺️ Nova Estratégia: Antecipando Views e Praticando PL/SQL a Fundo

Ao puxar **VIEWS** para o Dia 2, liberamos os Dias 3, 4 e 5 para praticar **Functions e Procedures** com muita repetição e profundidade, encapsulando os comandos DML, validações e consultas de prova dentro do código PL/SQL.

```
[DIA 1] Consultas Puras: Anti-Produto Cartesiano + Subqueries no SELECT / FROM
   │
[DIA 2] Agregações (GROUP BY / HAVING) + Extremos (Maior/Menor) + Início de VIEWS
   │
[DIA 3] DDL & DML encapsulados em PROCEDURES (INSERT, UPDATE, DELETE com Subqueries)
   │
[DIA 4] PL/SQL Avançado: FUNCTIONS no SELECT + PROCEDURES com IN, OUT e IN OUT
   │
[DIA 5] SIMULADO COMPLETO DE PROVA (Views, Procedures, Functions e Consultas Complexas)
```

---

## 📋 Detalhamento Dia a Dia

---

### 🔹 DIA 1: Anti-Produto Cartesiano & Subqueries Aninhadas
* **Status:** ✅ Concluído
* **Conteúdo:** Subqueries no `SELECT` com `DUAL`, subqueries no `FROM` (inline views), tratamento de nulos (`NVL`, `COALESCE`) e amarração analítica sem produto cartesiano.

---

### 🔹 DIA 2 (HOJE): Agregações Avançadas, Extremos & Início de VIEWS
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * Regra de ouro do `GROUP BY` (as caixas fechadas) e `WHERE` vs `HAVING`.
  * Como pescar o dono do Maior e Menor valor (`MAX` / `MIN` com subquery).
  * Funções numéricas: `ROUND`, `TRUNC` e proteção contra divisão por zero com `NULLIF`.
  * **VIEWS:** O que é uma `VIEW`, a analogia do Caderno de Receitas definitivo (`CREATE OR REPLACE VIEW`) e como consumir visões em outras consultas.
* **Prática no Banco `TRE_` (6 Exercícios):**
  * **Ex 1:** Treinos por usuário com `GROUP BY`, `ROUND` e filtro no `HAVING`.
  * **Ex 2:** Questão 2 do Professor (Maior média geral com `HAVING` e maior recorde com `WHERE`).
  * **Ex 3:** Séries por exercício com `MIN`, `MAX`, `AVG` e proteção `NULLIF`.
  * **Ex 4:** Questão 4 do Professor (Maior e menor recorde por grupo muscular e seus donos).
  * **Ex 5:** Criar a View `VW_DESEMPENHO_USUARIOS` consolidando treinos e tempos.
  * **Ex 6:** Criar a View `VW_RECORDES_POR_GRUPO` e consultar os dados consolidados.

---

### 🔹 DIA 3: DDL & DML Encapsulados em PROCEDURES
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * O que é uma `PROCEDURE` e por que encapsular comandos DML dentro dela.
  * `ALTER TABLE ... ADD` para criar colunas de controle.
  * `UPDATE` com subquery aninhada executado de dentro de uma Procedure.
  * `INSERT INTO ... SELECT` dentro de Procedure para registrar recordes e históricos automaticamente.
  * Parâmetros básicos `IN` e controle condicional com `IF ... THEN ... ELSE` (sem `EXCEPTION`).
* **Prática no Banco `TRE_`:**
  * Procedure para atualizar a categoria dos usuários (`'AVANÇADO'` / `'INICIANTE'`) via subquery (Questão 3 do professor adaptada).
  * Procedure para registrar histórico de séries e atualizar metas.

---

### 🔹 DIA 4: PL/SQL Avançado: FUNCTIONS & Parâmetros IN, OUT e IN OUT
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * **FUNCTIONS:** A cláusula `RETURN`, retorno de valores calculados e chamada direta dentro de comandos `SELECT`.
  * **Diferença crucial de parâmetros em Procedures:**
    * `IN`: leitura apenas.
    * `OUT`: escrita e retorno de valores.
    * `IN OUT`: entra com valor, modifica e devolve atualizado.
  * Funções condicionais e formatações (`CASE WHEN`, `TO_CHAR`).
* **Prática no Banco `TRE_`:**
  * Function que recebe `(ID_USUARIO, ID_EXERCICIO)` e retorna a maior carga já executada nas séries.
  * Function que retorna a % de conclusão de uma meta ativa.
  * Procedure completa usando `IN`, `OUT` e `IN OUT` para inserção, validação de pesos e retorno de status.

---

### 🔹 DIA 5: SIMULADO GERAL DE PROVA
* **Carga Horária:** ~2h00
* **Foco:** Prova simulada com tempo cronometrado cobrindo:
  1. Criação de View complexa analítica.
  2. Consulta de extremos com `GROUP BY` e `HAVING`.
  3. Criação de Function determinística para uso no `SELECT`.
  4. Criação de Procedure com parâmetros `IN` e `OUT` manipulando dados do banco.

---

## 🎯 Quadro de Progresso

| Dia | Tema Central | Status |
| :---: | :--- | :---: |
| **1** | Anti-Produto Cartesiano, Subqueries no SELECT/FROM, NVL, COALESCE | ✅ Concluído |
| **2** | Agregações (GROUP BY/HAVING), Extremos (Q2, Q4) + Início de VIEWS | ✅ Concluído |
| **3** | DDL & DML Encapsulados em PROCEDURES com Subqueries | ⏳ Em andamento |
| **4** | PL/SQL: FUNCTIONS no SELECT + PROCEDURES com IN, OUT, IN OUT | ⬜ A fazer |
| **5** | SIMULADO COMPLETO DE PROVA (Views, Procedures, Functions e SQL) | ⬜ A fazer |
