# 🏋️ DIA 3: DDL, Comandos DML com Subqueries & Domínio de PROCEDURES (IN, OUT, IN OUT)
> **Meta de Tempo:** 1h30 a 2h | **Foco:** Prática real no Oracle SQL & PL/SQL (`TRE_`)

---

## 🧠 PARTE 1: O GUIA DEFINITIVO (DIDÁTICA E ATALHOS MENTAIS)

---

### 1.1 O que é uma PROCEDURE? (A Analogia do Robô de Fábrica)

Até ontem, você digitava comandos `SELECT` manuais. O `SELECT` é passivo: ele só lê dados e mostra na tela.

Uma **`PROCEDURE`** é um **robô programado** que fica salvo dentro do banco de dados. 
* Você aperta um botão (executa a procedure) passando algumas instruções (parâmetros).
* O robô acorda, confere regras de negócio (`IF / THEN / ELSE`), faz alterações pesadas nas tabelas (**`INSERT`**, **`UPDATE`**, **`DELETE`**) e te devolve o resultado final ou mensagens no terminal.

```sql
CREATE OR REPLACE PROCEDURE nome_da_procedure (
    -- Parâmetros ficam aqui
)
IS
    -- Variáveis locais de apoio ficam aqui
BEGIN
    -- Comandos executáveis e regras de negócio ficam aqui
END;
/
```

---

### 1.2 Desmistificando os Parâmetros: `IN`, `OUT` e `IN OUT` (A Analogia dos Envelopes)

Essa é uma das coisas que mais caem em provas e concursos de banco de dados. A diferença entre os três modos de parâmetro é simples quando você pensa em **envelopes**:

```
           ┌────────────────────────┐
  p_in ───►│  PROCEDURE (Lê apenas) │
           └────────────────────────┘

           ┌────────────────────────┐
           │ PROCEDURE (Escreve)    │───► p_out
           └────────────────────────┘

           ┌────────────────────────┐
p_in_out ─►│ PROCEDURE (Lê e Altera)│───► p_in_out (modificado)
           └────────────────────────┘
```

---

#### ✉️ 1. Parâmetro `IN` (A Carta Selada - Entrada / Somente Leitura)
* **A Analogia:** É uma carta selada que você entrega para a procedure. O robô abre a carta, lê o que está escrito lá dentro (ex: o ID do usuário ou uma data), mas ele é **proibido de rabiscar ou alterar o valor da carta**.
* **Na Prática:** É o modo padrão. Se você não escrever nada na frente do parâmetro, o Oracle assume que ele é `IN`.
* **Regra de Ouro:** Dentro da procedure, você **NUNCA** pode fazer `param_in := 10;`. O Oracle dá erro de compilação na hora!

---

#### 📭 2. Parâmetro `OUT` (O Envelope em Branco - Saída / Escrita)
* **A Analogia:** Você entrega um envelope **completamente vazio** para a procedure. Lá dentro, o robô faz contas, consultas e regras, escreve uma resposta em uma folha, coloca dentro do envelope e **te devolve preenchido**.
* **Na Prática:** Ele entra nulo (`NULL`), é preenchido dentro do código com `param_out := resultado;` e, quando a procedure termina, o valor fica disponível para quem chamou.
* **Atenção:** A procedure não deve tentar ler o que veio de fora no parâmetro `OUT`, porque ele entra vazio!

---

#### 🔄 3. Parâmetro `IN OUT` (A Ficha de Treino que é Carimbada e Devolvida)
* **A Analogia:** Você chega na academia e entrega sua ficha de treino com um valor preenchido (ex: carga proposta = $4\text{ kg}$). O professor olha a ficha, vê que o mínimo permitido na máquina é $10\text{ kg}$, risca o $4$, anota $10$, carimba a ficha e **te devolve a mesma folha com o novo valor corrigido**!
* **Na Prática:** O parâmetro **entra com um valor**, a procedure **lê** esse valor, pode fazer cálculos ou validações nele (`param := param * 1.10;`), e **devolve o mesmo parâmetro modificado** para quem chamou.

---

### 📋 Resumo Comparativo dos Parâmetros

| Modo | Entra com valor de fora? | A Procedure pode alterar? | Devolve valor para fora? | Exemplo de Uso |
| :---: | :---: | :---: | :---: | :--- |
| **`IN`** | ✅ Sim | ❌ Não (Somente leitura) | ❌ Não | Passar o `ID_USUARIO` para filtrar uma busca |
| **`OUT`** | ❌ Não (Entra vazio) | ✅ Sim (Obrigatório preencher) | ✅ Sim | Devolver a mensagem `'SUCESSO'` ou o total calculado |
| **`IN OUT`** | ✅ Sim | ✅ Sim (Lê e modifica) | ✅ Sim (Sai com novo valor) | Passar um peso, aplicar correção e devolver o peso final |

---

### 🧪 Exemplo Real e Completo no nosso Banco (`IN` e `OUT`)

Veja como funciona na prática com a tabela `TRE_USUARIO` e `TRE_TREINO`.

#### 1. Criando a Procedure:
Queremos uma procedure que receba o `ID_USUARIO` (`IN`) e devolva o **Nome** e a **Quantidade de Treinos** (`OUT`):

```sql
CREATE OR REPLACE PROCEDURE PRC_DADOS_USUARIO (
    p_id_usuario    IN NUMBER,        -- ENTRA: o ID do aluno que queremos buscar
    p_nome_usuario  OUT VARCHAR2,     -- SAI: o nome encontrado
    p_total_treinos OUT NUMBER        -- SAI: a quantidade de treinos calculada
)
IS
BEGIN
    -- 1. Busca o nome do usuário e joga DIRETO no parâmetro OUT:
    SELECT NOME 
    INTO p_nome_usuario
    FROM TRE_USUARIO
    WHERE ID_USUARIO = p_id_usuario;

    -- 2. Conta os treinos dele e joga DIRETO no outro parâmetro OUT:
    SELECT COUNT(*)
    INTO p_total_treinos
    FROM TRE_TREINO
    WHERE ID_USUARIO = p_id_usuario;

    -- Fim! Não precisa de RETURN. 
    -- Quando o código acaba, os valores que estão em p_nome_usuario e p_total_treinos saem da procedure!
END;
/
```

#### 2. Como Chamar e Testar na Prova (O Bloco de Teste):
Como a procedure vai cuspir **duas respostas para fora**, você precisa de **duas "sacolas" (variáveis)** para receber o que sai:

```sql
SET SERVEROUTPUT ON;

DECLARE
    -- Criamos as 2 sacolas vazias para receber o que vai sair:
    v_nome_recebido  VARCHAR2(150);
    v_total_recebido NUMBER;
BEGIN
    -- Chamamos a procedure passando:
    -- O número 1 (para o IN) e as duas sacolas (para os dois OUTs):
    PRC_DADOS_USUARIO(1, v_nome_recebido, v_total_recebido);

    -- Agora que a procedure preencheu as sacolas, mostramos na tela:
    DBMS_OUTPUT.PUT_LINE('Aluno: ' || v_nome_recebido);
    DBMS_OUTPUT.PUT_LINE('Treinos Realizados: ' || v_total_recebido);
END;
/
```

> 💡 **O Fluxo Mental:**  
> 1. Você passa o número `1` $\rightarrow$ ele entra em `p_id_usuario` (`IN`).  
> 2. A procedure roda os `SELECT ... INTO` e preenche os dois parâmetros `OUT`.  
> 3. Quando a procedure termina, os valores são descarregados dentro das suas variáveis `v_nome_recebido` e `v_total_recebido`.  
> 4. O `DBMS_OUTPUT.PUT_LINE` imprime na tela o resultado!


---

### 1.3 Subqueries em Comandos DML (O que o Professor Pediu Expressamente)

O seu professor recomendou no grupo:  
> *"Recomendo que estudem os SELECT's aninhados nos outros comandos DML (INSERT, DELETE, UPDATE)."*

Veja como isso funciona na prática dentro de uma Procedure:

---

#### 1. `UPDATE` com Subquery Aninhada (A Questão 3 do Professor):
Em vez de atualizar linha por linha, você atualiza um grupo inteiro filtrado pelo resultado de uma consulta:
```sql
UPDATE TRE_USUARIO
SET CATEGORIA = 'AVANÇADO'
WHERE ID_USUARIO IN (
    -- Subquery aninhada: descobre quem tem recordes pesados
    SELECT DISTINCT ID_USUARIO 
    FROM TRE_RECORD 
    WHERE CARGA_RECORD >= 100
);
```

#### 2. `INSERT INTO ... SELECT` (Carga Automática de Históricos):
Você não precisa digitar `VALUES (...)`. Você pode mandar o banco pegar o resultado de um `SELECT` e jogar direto dentro de outra tabela:
```sql
INSERT INTO TRE_RECORD (ID_USUARIO, ID_EXERCICIO, COD_RECORD, CARGA_RECORD, DATA_RECORD)
SELECT 
    t.ID_USUARIO,
    it.ID_EXERCICIO,
    'REC-AUTO-' || TO_CHAR(SYSDATE, 'YYYYMMDD-HH24MISS'),
    MAX(s.CARGA),
    TRUNC(SYSDATE)
FROM TRE_TREINO t
JOIN TRE_ITEM_TREINO it ON it.ID_TREINO = t.ID_TREINO
JOIN TRE_SERIE s ON s.ID_ITEM_TREINO = it.ID_ITEM_TREINO
WHERE t.ID_USUARIO = p_id_usuario
GROUP BY t.ID_USUARIO, it.ID_EXERCICIO;
```

#### 3. `DELETE` Seguro com Subquery:
Deletar registros órfãos que não possuem filhos associados:
```sql
DELETE FROM TRE_TREINO
WHERE ID_TREINO NOT IN (
    -- Subquery aninhada: treinos que possuem pelo menos um item
    SELECT DISTINCT ID_TREINO 
    FROM TRE_ITEM_TREINO
);
```

---

### 1.4 Operadores de Conjunto: `IN` e `NOT IN` com Subqueries

Cuidado para não confundir:
* Uma coisa é o **modo de parâmetro `IN`** da Procedure (`p_id IN NUMBER`), que significa "somente-leitura".
* Outra coisa completamente diferente são os **operadores `IN` e `NOT IN`** usados no `WHERE` das consultas SQL!

#### 🎟️ 1. O Operador `IN` (A Lista de Convidados VIP)
Ele verifica se o valor da linha pertence a uma lista gerada por uma subquery:
```sql
UPDATE TRE_USUARIO
SET CATEGORIA = 'AVANÇADO'
WHERE ID_USUARIO IN (
    SELECT DISTINCT ID_USUARIO 
    FROM TRE_RECORD 
    WHERE CARGA_RECORD >= 100
);
```
> **Como o banco lê:** A subquery gera uma listinha de IDs que levantaram mais de 100kg (ex: `1, 2, 4`). O `UPDATE` só altera os usuários cujo `ID_USUARIO` estiver dentro dessa lista!

#### 🚫 2. O Operador `NOT IN` (A Lista Negra)
Ele faz o inverso: só deixa passar quem **NÃO** está na lista gerada pela subquery:
```sql
SELECT * FROM TRE_EXERCICIO
WHERE ID_EXERCICIO NOT IN (
    SELECT DISTINCT ID_EXERCICIO FROM TRE_ITEM_TREINO
);
```
*(Tradução: Traga todos os exercícios cadastrados que **NUNCA** foram usados em nenhum treino).*

> ⚠️ **A PEGADINHA MORTAL DE PROVA: O `NULL` no `NOT IN`!**  
> Se a subquery de dentro do `NOT IN` devolver **um único valor `NULL`**, a consulta inteira trava e **devolve ZERO linhas** (nada)!  
> **A Regra de Ouro:** Sempre que usar `NOT IN` com subquery, garanta que não venham nulos colocando `WHERE coluna IS NOT NULL` dentro da subquery:
> ```sql
> WHERE ID_EXERCICIO NOT IN (
>     SELECT ID_EXERCICIO FROM TRE_ITEM_TREINO WHERE ID_EXERCICIO IS NOT NULL
> )
> ```

---

### 1.5 O Contador Secreto do Oracle: `SQL%ROWCOUNT`

Sempre que você roda um `UPDATE`, `INSERT` ou `DELETE` dentro de uma Procedure, o Oracle atualiza automaticamente uma variável oculta chamada **`SQL%ROWCOUNT`**.
* Ela guarda **o número exato de linhas que foram afetadas** pelo último comando DML executado!
* *Exemplo:*
  ```sql
  UPDATE TRE_USUARIO SET CATEGORIA = 'AVANÇADO' WHERE ...;
  DBMS_OUTPUT.PUT_LINE('Total de alunos promovidos: ' || SQL%ROWCOUNT);
  ```


---

## 📝 PARTE 2: ATIVIDADES PRÁTICAS DO DIA 3

---

### 🎯 EXERCÍCIO 1 (Procedure Básica com Parâmetro IN e DBMS_OUTPUT)
Crie uma procedure chamada **`PRC_CONSULTAR_TREINOS_USUARIO`** que receba:
* `p_id_usuario IN NUMBER`

**Regras de Negócio da Procedure:**
1. Declare variáveis locais para guardar o nome do usuário, a quantidade de treinos e a maior duração de treino.
2. Execute um comando `SELECT ... INTO ...` na tabela `TRE_TREINO` e `TRE_USUARIO` buscando os dados daquele usuário específico.
3. Exiba o resultado no terminal com `DBMS_OUTPUT.PUT_LINE` no seguinte formato:  
   `"Usuario: [NOME] | Total de Treinos: [QTD] | Maior Treino: [MAIOR] minutos."`

**Exigências:**
* Usar `CREATE OR REPLACE PROCEDURE`.
* Parâmetro de entrada `IN`.
* Usar `SELECT ... INTO ...`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O `SELECT ... INTO` junta `TRE_USUARIO` e `TRE_TREINO`, filtra por `WHERE u.ID_USUARIO = p_id_usuario` e agrupa por `u.NOME` para calcular `COUNT(t.ID_TREINO)` e `MAX(t.DURACAO_MINUTO)`.

---

### 🎯 EXERCÍCIO 2 (Adaptação da Questão 3 do Professor: DDL + UPDATE com Subquery)
O professor pediu: *"Criar e atualizar campo... quantos homens e mulheres?"*

No nosso banco:
1. **Passo DDL prévio:** Execute o comando para criar a coluna `CATEGORIA`:
   ```sql
   ALTER TABLE TRE_USUARIO ADD CATEGORIA VARCHAR2(20) DEFAULT 'INICIANTE';
   ```
2. **Crie uma procedure chamada `PRC_ATUALIZAR_CATEGORIAS` (sem parâmetros):**
   * Ela deve rodar um comando `UPDATE` na tabela `TRE_USUARIO` alterando o campo `CATEGORIA` para `'AVANÇADO'` de todos os usuários que possuam pelo menos um recorde cadastrado em `TRE_RECORD` com `CARGA_RECORD >= 100.00` (utilizando subquery aninhada no `WHERE`).
   * Em seguida, imprima no terminal com `DBMS_OUTPUT.PUT_LINE` a quantidade de usuários atualizados usando o contador `SQL%ROWCOUNT`.

**Exigências:**
* Usar `UPDATE` com subquery aninhada (`WHERE ID_USUARIO IN (SELECT ...)`).
* Usar `SQL%ROWCOUNT`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O comando `UPDATE` usa `WHERE ID_USUARIO IN (SELECT DISTINCT ID_USUARIO FROM TRE_RECORD WHERE CARGA_RECORD >= 100)`. Logo na linha seguinte, coloque `DBMS_OUTPUT.PUT_LINE('Usuarios atualizados: ' || SQL%ROWCOUNT);`.

---

### 🎯 EXERCÍCIO 3 (Dominando Parâmetros OUT e IN OUT com Regra de Negócio)
Crie uma procedure chamada **`PRC_VALIDAR_PROGRESSAO`** que receba:
* `p_id_usuario IN NUMBER` (Parâmetro de entrada)
* `p_id_exercicio IN NUMBER` (Parâmetro de entrada)
* `p_carga_proposta IN OUT NUMBER` (Parâmetro de entrada e saída)
* `p_status_meta OUT VARCHAR2` (Parâmetro de saída)

**Regras de Negócio da Procedure:**
1. **Validação do `IN OUT`:** Se a carga proposta que entrou (`p_carga_proposta`) for menor que $5.00\text{ kg}$, a procedure deve corrigir automaticamente o valor para $5.00\text{ kg}$ (`p_carga_proposta := 5.00;`).
2. Busque a carga alvo da meta ativa desse usuário para esse exercício em `TRE_META` onde `STATUS = 'ATIVA'` (armazene em uma variável local `v_carga_alvo`).
3. **Avaliação da meta com `IF / THEN / ELSE`:**
   * Se `p_carga_proposta >= v_carga_alvo`:  
     Preencha o parâmetro de saída com `p_status_meta := 'BATE OU SUPERA A META ATIVA';`
   * Caso contrário:  
     Preencha o parâmetro de saída com `p_status_meta := 'ABAIXO DA META ATIVA';`
4. Escreva o **Bloco Anônimo de Teste (`DECLARE ... BEGIN ... END;`)** para rodar a procedure passando as variáveis e imprimir os valores retornados com `DBMS_OUTPUT.PUT_LINE`.

**Exigências:**
* Declarar e usar corretamente os parâmetros `IN`, `OUT` e `IN OUT`.
* Condicional com `IF ... THEN ... ELSE`.
* Sem bloco `EXCEPTION`.
* Fornecer o bloco de teste com `SET SERVEROUTPUT ON`.

💡 **Dica de Raciocínio:** O `IN OUT` entra com um peso qualquer (ex: 3kg). O `IF` verifica se é menor que 5kg e reatribui para 5kg. Depois, o `SELECT CARGA_ALVO INTO v_carga_alvo` busca a meta e compara com o novo peso. O resultado da mensagem é gravado em `p_status_meta`.

---

### 🎯 EXERCÍCIO 4 (INSERT INTO ... SELECT com Subquery Aninhada em Procedure)
Crie uma procedure chamada **`PRC_SINCRONIZAR_RECORDES`** que receba:
* `p_id_usuario IN NUMBER`

**Regras de Negócio da Procedure:**
A procedure deve executar um comando `INSERT INTO TRE_RECORD (ID_USUARIO, ID_EXERCICIO, COD_RECORD, CARGA_RECORD, DATA_RECORD)` selecionando diretamente das séries realizadas por esse usuário (`TRE_SERIE`) as maiores cargas levantadas em cada exercício que sejam estritamente superiores ao maior recorde atual daquele usuário naquele exercício.
* O código do recorde deve ser gerado dinamicamente: `'REC-AUT-' || TO_CHAR(t.ID_USUARIO) || '-' || TO_CHAR(it.ID_EXERCICIO)`
* A data do recorde deve ser `TRUNC(SYSDATE)`.
* Ao final, imprima no terminal com `DBMS_OUTPUT.PUT_LINE` quantos novos recordes foram inseridos usando `SQL%ROWCOUNT`.

**Exigências:**
* Usar `INSERT INTO ... SELECT ...`.
* Usar subquery aninhada para checar se a carga da série é maior que o recorde atual do usuário.
* Usar `SQL%ROWCOUNT`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O `INSERT INTO ... SELECT` agrupa séries por usuário e exercício calculando `MAX(s.CARGA)`. Na cláusula `HAVING` do `SELECT`, compare se `MAX(s.CARGA) > (SELECT NVL(MAX(r.CARGA_RECORD), 0) FROM TRE_RECORD r WHERE r.ID_USUARIO = t.ID_USUARIO AND r.ID_EXERCICIO = it.ID_EXERCICIO)`.

---

### 🎯 EXERCÍCIO 5 (DELETE Seguro com NOT IN e Proteção IS NOT NULL)
Crie uma procedure chamada **`PRC_LIMPAR_TREINOS_ORFAOS`** (sem parâmetros).

**Regras de Negócio da Procedure:**
1. A procedure deve executar um comando `DELETE` na tabela `TRE_TREINO` removendo todos os treinos que não possuem nenhum item associado na tabela `TRE_ITEM_TREINO`.
2. A condição de exclusão deve usar obrigatoriamente `WHERE ID_TREINO NOT IN (SELECT ...)` garantindo a proteção contra nulos com `WHERE ID_TREINO IS NOT NULL`.
3. Ao final, imprima com `DBMS_OUTPUT.PUT_LINE` a quantidade de treinos órfãos removidos usando `SQL%ROWCOUNT`.

**Exigências:**
* Usar `DELETE` com subquery aninhada usando `NOT IN`.
* Usar `WHERE ID_TREINO IS NOT NULL` dentro da subquery do `NOT IN`.
* Usar `SQL%ROWCOUNT` e `DBMS_OUTPUT.PUT_LINE`.
* Sem bloco `EXCEPTION`.

💡 **Dica de Raciocínio:** O comando fica `DELETE FROM TRE_TREINO WHERE ID_TREINO NOT IN (SELECT DISTINCT ID_TREINO FROM TRE_ITEM_TREINO WHERE ID_TREINO IS NOT NULL);`. Em seguida, imprima o total de excluídos com `SQL%ROWCOUNT`.

