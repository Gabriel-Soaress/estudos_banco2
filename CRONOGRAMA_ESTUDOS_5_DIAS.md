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
* **Status:** ✅ Concluído
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * O que é uma `PROCEDURE` e por que encapsular comandos DML dentro dela.
  * Parâmetros `IN`, `OUT` e `IN OUT` (a analogia dos envelopes).
  * `UPDATE` com subquery aninhada executado de dentro de uma Procedure (Questão 3 adaptada).
  * Operadores `IN` e `NOT IN` com subqueries e a proteção contra `NULL` (`IS NOT NULL`).
  * Contador nativo `SQL%ROWCOUNT`.
  * `DELETE` seguro com subquery aninhada.
  * Parâmetros `IN OUT` e controle condicional com `IF ... ELSIF ... ELSE` (sem `EXCEPTION`).

---

### 🔹 DIA 4: PL/SQL Avançado: FUNCTIONS & Parâmetros IN, OUT e IN OUT
* **Status:** ✅ Concluído
* **Carga Horária:** ~2h00
* **Foco Teórico:**
  * **FUNCTIONS:** A cláusula `RETURN`, retorno de valores calculados e chamada direta dentro de comandos `SELECT`.
  * **Diferença crucial de parâmetros em Procedures:**
    * `IN`: leitura apenas.
    * `OUT`: escrita e retorno de valores (obrigatoriamente variáveis de memória).
    * `IN OUT`: entra com valor, modifica e devolve atualizado.
  * O poder do `%ROWTYPE` (a maleta completa da tabela).
  * Vigência temporal de metas e cruzamento com recordes (`BETWEEN`).
  * Procedimento modularizado consumindo Function dentro do `UPDATE`.
* **Prática no Banco `TRE_` (5 Exercícios Concluídos):**
  * `FNC_MAIOR_CARGA_USUARIO` chamada no `SELECT` da tabela de usuários.
  * `FNC_STATUS_PROGRESSO_META` com `CASE WHEN` avaliando a meta.
  * `TRE_REGISTRAR_SERIE` com saneamento via `IN OUT`, código sequencial e `SQL%ROWCOUNT`.
  * `PRC_ATUALIZAR_RECORDES_USUARIO` modularizada consumindo a função de maior carga.
  * `FNC_RECORDES_NA_VIGENCIA_META` usando `%ROWTYPE` e vigência temporal.

---

### 🔹 DIA 5: SIMULADO GERAL DE PROVA & REVISÃO
* **Status:** ✅ Concluído (Simulado Teórico 10/10 + Simulado Prático 9,1/10)
* **Carga Horária:** ~2h00
* **Foco:** Prova simulada completa (Fase 1 Teórica/Caça aos Bugs + Fase 2 Prática no SQL Developer) cobrindo:
  1. Relatório gerencial sem Produto Cartesiano (`SELECT` + Subqueries).
  2. Criação de `VIEW` analítica com vigência temporal e `CASE WHEN`.
  3. `UPDATE` em lote com subquery correlacionada.
  4. `PROCEDURE` com conversão `COD_` $\rightarrow$ `ID_`, validação `IF/ELSE` e parâmetro `OUT`.
  5. `FUNCTION` de volume total + `PROCEDURE` de maior volume com desempate `MIN`.

---

## 🎯 Quadro de Progresso

| Dia | Tema Central | Status |
| :---: | :--- | :---: |
| **1** | Anti-Produto Cartesiano, Subqueries no SELECT/FROM, NVL, COALESCE | ✅ Concluído |
| **2** | Agregações (GROUP BY/HAVING), Extremos (Q2, Q4) + Início de VIEWS | ✅ Concluído |
| **3** | DDL & DML Encapsulados em PROCEDURES com Subqueries | ✅ Concluído |
| **4** | PL/SQL: FUNCTIONS no SELECT + PROCEDURES com IN, OUT, IN OUT | ✅ Concluído |
| **5** | SIMULADO COMPLETO DE PROVA (Views, Procedures, Functions e SQL) | ✅ Concluído |
