# 🏋️ DIA 2: GROUP BY, Agregações Avançadas, Extremos (Maior/Menor), Funções Numéricas & Início de VIEWS
> **Meta de Tempo:** 1h30 a 2h | **Foco:** Prática real no Oracle SQL (`TRE_`)

---

## 🧠 PARTE 1: O GUIA DEFINITIVO (DIDÁTICA E ATALHOS MENTAIS)

---

### 2.1 A Regra de Ouro do `GROUP BY` (A Analogia das Caixas Fechadas)

Imagine que você tem centenas de fichas de treino espalhadas no chão.
Quando você escreve `GROUP BY u.NOME`, você está pegando caixas de papelão e escrevendo o nome de cada aluno do lado de fora da caixa. Depois, joga todas as fichas do Lucas dentro da caixa do Lucas, e as fichas do Gabriel na caixa do Gabriel.

Agora você fecha a tampa da caixa com fita adesiva.

> 🚨 **A REGRA QUE NUNCA PODE SER QUEBRADA NA PROVA:**  
> Do lado de fora da caixa, você só consegue enxergar duas coisas:
> 1. **O que está escrito na etiqueta da caixa** (as colunas que estão no `GROUP BY`).
> 2. **Medições do conteúdo total da caixa** (funções de agregação como contar quantas fichas tem dentro: `COUNT`, somar os pesos: `SUM`, tirar a média: `AVG`, ou pegar o maior/menor peso: `MAX` / `MIN`).

Se você tentar colocar uma coluna solta no `SELECT` (por exemplo, `t.DATA_TREINO`) sem ter colocado na etiqueta (`GROUP BY`) e sem uma função agregada, o Oracle dá o erro clássico:  
`ORA-00979: not a GROUP BY expression`.  
**Por quê?** Porque dentro da caixa do Lucas tem 10 datas diferentes, e o banco não tem bola de cristal para adivinhar qual data você quer mostrar para aquela caixa única!

---

### 2.2 `WHERE` vs `HAVING` (A Peneira Grossa vs O Controle de Qualidade)

Essa é uma das pegadinhas favoritas de prova. Ambos filtram coisas, mas em momentos **completamente diferentes**:

* **`WHERE` (A Peneira Grossa - ANTES de agrupar):**  
  Ele olha ficha por ficha individualmente antes de jogar na caixa.  
  *Exemplo:* *"Só coloque na caixa as séries feitas com carga maior que 50kg (`WHERE s.CARGA > 50`)"*.
* **`HAVING` (O Controle de Qualidade - DEPOIS de agrupar):**  
  Ele só entra em ação depois que as caixas já estão fechadas e as médias e somas já foram calculadas.  
  *Exemplo:* *"Só mostre as caixas dos alunos cuja média de peso passou de 80kg (`HAVING AVG(s.CARGA) > 80`)"*.

```
   [Tabelas Cruas com Linhas Soltas]
                 │
                 ▼
          FILTRO COM 'WHERE' (Elimina linhas individuais)
                 │
                 ▼
          AGRUPAMENTO COM 'GROUP BY' (Fecha as caixas e calcula somas/médias)
                 │
                 ▼
          FILTRO COM 'HAVING' (Elimina caixas inteiras com base no resultado da agregação)
```

> ⚠️ **NUNCA FAÇA ISSO:** `WHERE AVG(s.CARGA) > 80`.  
> O Oracle vai cuspir erro na hora (`ORA-00934: group function is not allowed here`), porque na hora do `WHERE` o banco ainda está olhando linha por linha e a média nem existe ainda!

---

### 2.3 Como Pescar o "Dono" do Maior ou Menor Valor (O Padrão de Prova)

Se o professor pedir: *"Qual é a maior carga levantada?"*, você faz:
```sql
SELECT MAX(CARGA_RECORD) FROM TRE_RECORD;
```
O banco responde: `320.00`.

Mas se ele pedir: *"Qual o NOME do usuário e o NOME do exercício que possuem essa maior carga?"*, você **NÃO PODE** simplesmente fazer:
```sql
-- ❌ ERRO DE PROVA! O Oracle não sabe de quem é esse MAX!
SELECT u.NOME, e.NOME, MAX(r.CARGA_RECORD)
FROM TRE_RECORD r
JOIN TRE_USUARIO u ON u.ID_USUARIO = r.ID_USUARIO
JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = r.ID_EXERCICIO;
```

#### Como se resolve? Com Subquery no `WHERE`!
Você faz uma subquery que descobre o valor máximo primeiro, e usa ela no filtro do `WHERE`:

```sql
SELECT u.NOME AS USUARIO, e.NOME AS EXERCICIO, r.CARGA_RECORD
FROM TRE_RECORD r
JOIN TRE_USUARIO u ON u.ID_USUARIO = r.ID_USUARIO
JOIN TRE_EXERCICIO e ON e.ID_EXERCICIO = r.ID_EXERCICIO
WHERE r.CARGA_RECORD = (
    -- Subquery aninhada que descobre o teto máximo de todo o banco:
    SELECT MAX(CARGA_RECORD) 
    FROM TRE_RECORD
);
```
> **Como o banco pensa:** Primeiro ele roda a subquery de dentro e acha `320.00`. Depois ele busca quem é a linha que tem exatamente `CARGA_RECORD = 320.00` e traz o nome do dono e do exercício!

---

### 2.4 Funções Auxiliares Numéricas do Dia 2

| Função | O que ela faz | A Analogia / Aplicação | Exemplo no Banco |
| :--- | :--- | :--- | :--- |
| **`ROUND(num, decimais)`** | Arredonda o número para as casas decimais que você pedir. | **O cosmético das médias:** Um `AVG()` cospe `73.33333333`. Em relatórios, você usa `ROUND` para ficar `73.33`. | `ROUND(AVG(s.CARGA), 2)` |
| **`TRUNC(num, decimais)`** | Corta o número sem arredondar. | **A tesoura cega:** Se o número for `73.389`, o `TRUNC(..., 2)` devolve `73.38` direto, sem arredondar para cima. | `TRUNC(AVG(s.CARGA), 2)` |
| **`NULLIF(a, b)`** | Retorna `NULL` se `a` for exatamente igual a `b`. | **O extintor de incêndio:** Evita o erro fatal `ORA-01476: divisor is equal to zero`. Se você dividir algo por zero, o banco cai. Se dividir por `NULLIF(total, 0)`, ele vira `NULL` suavemente sem estourar erro. | `CARGA_TOTAL / NULLIF(QTD_SERIES, 0)` |

---

### 2.5 Início de VIEWS: Do "Post-it" ao "Caderno Definitivo"

Ontem você aprendeu que uma subquery no `FROM` é uma **Inline View (um Post-it temporário)**: você usa na hora entre parênteses e o banco descarta da memória assim que a consulta termina.

Agora vamos dar o próximo passo: **E se você quiser guardar esse relatório para sempre no banco com um nome fixo?**  
Você cria uma **`VIEW`**!

```sql
CREATE OR REPLACE VIEW nome_da_view AS
SELECT colunas, agregacoes
FROM tabelas
GROUP BY colunas;
```

* **A Analogia do Caderno de Receitas:**  
  Em vez de ficar reescrevendo uma consulta gigante de 20 linhas cheia de `JOIN`s toda vez que alguém pedir um relatório, você salva a receita uma única vez no banco.
* **Como consultar uma View depois de criada:**  
  Exatamente como se ela fosse uma tabela comum:
  ```sql
  SELECT * FROM nome_da_view WHERE CONDICAO;
  ```
* **Por que os professores adoram cobrar Views?**  
  1. **Simplificação:** O usuário final não precisa saber fazer `JOIN` nem subquery; ele só dá `SELECT * FROM VW_...`.
  2. **Segurança:** Você pode dar permissão para o estagiário ver a View com o resumo das cargas, sem deixar ele ver a tabela de senhas dos usuários.

---

## 📝 PARTE 2: ATIVIDADES PRÁTICAS DO DIA 2

---

### 🎯 EXERCÍCIO 1 (Agregações Básicas com HAVING e ROUND)
Crie um comando `SELECT` que consulte a tabela de treinos (`TRE_TREINO`) e usuários (`TRE_USUARIO`) e retorne:
* Nome do usuário (`u.NOME`)
* Quantidade total de treinos realizados
* Média de duração dos treinos em minutos (`DURACAO_MINUTO`), arredondada para 2 casas decimais

**Exigências:**
* Usar `GROUP BY`.
* Arredondar a média com `ROUND`.
* Exibir apenas os usuários que realizaram **mais de 1 treino**, filtrando esse total através da cláusula `HAVING`.

💡 **Dica de Raciocínio:** Junte `TRE_USUARIO` e `TRE_TREINO`, agrupe pelas colunas necessárias do usuário, calcule `COUNT` e `AVG`, e use o `HAVING` para cortar quem tem apenas 1 treino.

---

### 🎯 EXERCÍCIO 2 (Adaptação da Questão 2 do Professor: Extremos Globais)
O seu professor colocou na lista dele: *"Qual aluno com a maior média e em qual disciplina foi a maior nota?"*

No nosso banco, resolva as duas partes correspondentes:

* **Parte A (A Maior Média Geral):**  
  Crie um comando `SELECT` que retorne o **Nome do usuário** e a sua **Média geral de carga** levantada em todas as suas séries (arredondada em 2 casas decimais), trazendo **apenas o usuário que tem a maior média geral de todo o sistema**.
  *Exigência:* Usar `GROUP BY` e filtrar a maior média no `HAVING` comparando com uma subquery que calcula `MAX(AVG(CARGA))`.

* **Parte B (A Maior Carga Absoluta do Sistema):**  
  Crie um comando `SELECT` que retorne o **Nome do exercício** e a **Carga do recorde** onde ocorreu o maior recorde cadastrado de todo o banco (`TRE_RECORD`).
  *Exigência:* Usar `WHERE` comparando com uma subquery escalar que busca o `MAX(CARGA_RECORD)`.

💡 **Dica de Raciocínio:** Na Parte A, agrupe as séries por usuário e use `HAVING AVG(s.CARGA) = (SELECT MAX(AVG(s2.CARGA)) FROM ...)`. Na Parte B, use `WHERE r.CARGA_RECORD = (SELECT MAX(CARGA_RECORD) FROM TRE_RECORD)`.

---

### 🎯 EXERCÍCIO 3 (Múltiplas Agregações e Proteção com NULLIF)
Crie um comando `SELECT` que consulte os exercícios e suas séries executadas, agrupando por exercício (`TRE_EXERCICIO`), retornando:
* Nome do exercício (`e.NOME`)
* Quantidade total de séries executadas daquele exercício
* Menor carga levantada em séries (`MIN`)
* Maior carga levantada em séries (`MAX`)
* Média de carga levantada, arredondada em 2 casas decimais
* Média calculada manualmente de repetições por série dividindo a soma total de repetições pela quantidade de séries, protegendo o divisor contra zero com `NULLIF`.

**Exigências:**
* Usar `GROUP BY`.
* Usar `COUNT`, `MIN`, `MAX`, `AVG`, `ROUND` e `NULLIF`.
* Não usar `WITH`.

💡 **Dica de Raciocínio:** Junte `TRE_EXERCICIO`, `TRE_ITEM_TREINO` e `TRE_SERIE`. No `SELECT`, aplique cada função agregada. Para o cálculo com `NULLIF`, faça `SUM(s.REPETICOES) / NULLIF(COUNT(s.ID_SERIE), 0)`.

---

### 🎯 EXERCÍCIO 4 (Adaptação da Questão 4 do Professor: Extremos por Categoria)
O seu professor colocou na lista dele: *"Homens com maior e menor nota; Mulheres idem..."*

No nosso banco:  
Para cada **Grupo Muscular** (`TRE_GRUPOMUSCULAR`), liste em uma única consulta:
* Nome do Grupo Muscular (`g.NOME`)
* Valor da Maior Carga Recorde daquele grupo
* Valor da Menor Carga Recorde daquele grupo
* Nome do Exercício que possui essa maior carga recorde
* Nome do Exercício que possui essa menor carga recorde

**Exigências:**
* Usar uma **subquery aninhada no `FROM`** para agrupar os recordes por grupo muscular (`MAX` e `MIN`), e juntar com `TRE_GRUPOMUSCULAR`.
* Usar **subqueries correlacionadas** para capturar o nome do exercício da maior carga e o nome do exercício da menor carga.
* Não usar `WITH` nem `UNION`.

💡 **Dica de Raciocínio:** No `FROM`, crie a view temporária agrupando `TRE_RECORD` + `TRE_EXERCICIO` por `ID_GRP_MUSCULAR` calculando `MAX(CARGA_RECORD)` e `MIN(CARGA_RECORD)`. Do lado de fora, faça `JOIN` com `TRE_GRUPOMUSCULAR` e use subqueries no `JOIN` ou no `SELECT` para buscar o nome do exercício que atinge aquele valor máximo/mínimo naquele grupo.

---

### 🎯 EXERCÍCIO 5 (Criando sua primeira VIEW Analítica)
Crie uma VIEW chamada **`VW_DESEMPENHO_USUARIOS`** que consolide o histórico de treinos de cada usuário, contendo:
* `ID_USUARIO`: Identificador do usuário
* `NOME_USUARIO`: Nome do usuário
* `TOTAL_TREINOS`: Quantidade total de treinos realizados
* `MEDIA_DURACAO_MIN`: Duração média dos treinos em minutos, arredondada para 2 casas decimais
* `MAIOR_DURACAO_MIN`: Duração do treino mais longo realizado pelo usuário

**Exigências:**
* Usar o comando `CREATE OR REPLACE VIEW`.
* Usar `GROUP BY` e as funções de agregação apropriadas (`COUNT`, `AVG`, `MAX`, `ROUND`).

💡 **Dica de Raciocínio:** Escreva primeiro o comando `SELECT` juntando `TRE_USUARIO` e `TRE_TREINO` com o `GROUP BY`. Quando ele estiver rodando liso, basta colocar `CREATE OR REPLACE VIEW VW_DESEMPENHO_USUARIOS AS` antes dele!

---

### 🎯 EXERCÍCIO 6 (Criando e Consumindo uma VIEW de Ranking de Cargas)
Crie uma VIEW chamada **`VW_RESUMO_EXERCICIOS`** contendo:
* `ID_EXERCICIO`: Identificador do exercício
* `NOME_EXERCICIO`: Nome do exercício
* `TOTAL_SERIES`: Quantidade total de séries realizadas naquele exercício
* `MAIOR_CARGA`: Maior carga já levantada em séries daquele exercício
* `MEDIA_CARGA`: Média de carga levantada, arredondada para 2 casas decimais

Logo após o comando de criação da View, escreva uma consulta `SELECT` que utilize a **`VW_RESUMO_EXERCICIOS`** para listar apenas os exercícios que possuem `MAIOR_CARGA >= 100.00`.

**Exigências:**
* Criar a View com `CREATE OR REPLACE VIEW`.
* Escrever o `SELECT` consumidor filtrando a própria View através da cláusula `WHERE`.

💡 **Dica de Raciocínio:** A View encapsula toda a complexidade de cruzar `TRE_EXERCICIO`, `TRE_ITEM_TREINO` e `TRE_SERIE`. Depois que ela existir, sua segunda consulta será tão simples quanto `SELECT ... FROM VW_RESUMO_EXERCICIOS WHERE MAIOR_CARGA >= 100`.
