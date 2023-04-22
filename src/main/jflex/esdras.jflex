import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;

enum Classe {
    cId,
    cInt,
    cReal,
    cPalRes,
    cDoisPontos,
    cAtribuicao,
    cMais,
    cMenos,
    cDivisao,
    cMultiplicacao,
    cMaior,
    cMenor,
    cMaiorIgual,
    cMenorIgual,
    cDiferente,
    cIgual,
    cVirgula,
    cPontoVirgula,
    cPonto,
    cParEsq,
    cParDir,
    cString,
    cEOF,
}
class Valor {
    private int valorInteiro;
    private double valorDecimal;
    private String valorIdentificador;

    public Valor() {
    }

    public Valor(double valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    public Valor(int valorInteiro) {
        this.valorInteiro = valorInteiro;
    }

    public Valor(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
    }

    public int getValorInteiro() {
        return valorInteiro;
    }

    public void setValorInteiro(int valorInteiro) {
        this.valorInteiro = valorInteiro;
    }

    public double getValorDecimal() {
        return valorDecimal;
    }

    public void setValorDecimal(double valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    public String getValorIdentificador() {
        return valorIdentificador;
    }

    public void setValorIdentificador(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
    }

    @Override
    public String toString() {
        return "Valor{" +
                "valorInteiro=" + valorInteiro +
                ", valorDecimal=" + valorDecimal +
                ", valorIdentificador='" + valorIdentificador + '\'' +
                '}';
    }
}

class Token {
    private Classe classe;
    private Valor valor;
    private int linha;
    private int coluna;

    public Token(int linha, int coluna, Classe classe) {
            this.linha = linha;
            this.coluna = coluna;
            this.classe = classe;
    }

    public Token(int linha, int coluna, Classe classe, Valor valor) {
          this.classe = classe;
          this.valor = valor;
          this.linha = linha;
          this.coluna = coluna;
    }

    public Classe getClasse() {
        return classe;
    }

    public void setClasse(Classe classe) {
        this.classe = classe;
    }

    public Valor getValor() {
        return valor;
    }

    public void setValor(Valor valor) {
        this.valor = valor;
    }

    public int getLinha() {
        return linha;
    }

    public void setLinha(int linha) {
        this.linha = linha;
    }

    public int getColuna() {
        return coluna;
    }

    public void setColuna(int coluna) {
        this.coluna = coluna;
    }

    @Override
    public String toString() {
        return "Token{" +
                "classe=" + classe +
                ", valor=" + valor +
                ", linha=" + linha +
                ", coluna=" + coluna +
                '}';
    }
}

%%

%class AnalisadorLexico
%type Token
%unicode
%column
%line


DIGITO = [0-9]
LETRA = [A-Za-z]
INTEIRO = 0 | [1-9]{DIGITO}*
IDENTIFICADOR = {LETRA}({LETRA}|{DIGITO})*
STRING = \"[^\"]*\"

REAL = {INTEIRO}\.{DIGITO}+
PALAVRA_RESERVADA = "and"|"array"|"begin"|"case"|"const"|"div"|"do"|"downto"|"else"|"end"|"file"|"for"|"function"|"goto"|"if"|"in"|"label"|"mod"|"nil"|"not"|"of"|"or"|"packed"|"procedure"|"program"|"record"|"repeat"|"set"|"then"|"to"|"type"|"until"|"var"|"while"|"with"
OPERADORES = ":="|">="|"<="|"<>"|"="|":"|"\+"|"-"|"/"|"*"|">"|"<"|","|";"|"."
PARENTESES = "\(" | "\)"

FIMLINHA = [\r\n]+
ESPACO = {FIMLINHA} | [ \t\f]
%{
public static void main(String[] argv) {
        if (argv.length == 0) {
            System.out.println("Usage : java Analisador Lexico [ --encoding <name> ] <inputfile(s)>");
        } else {
            int firstFilePos = 0;
            String encodingName = "UTF-8";
            if (argv[0].equals("--encoding")) {
                firstFilePos = 2;
                encodingName = argv[1];
                try {
                    Charset.forName(encodingName);
                } catch (Exception e) {
                    System.out.println("Invalid encoding '" + encodingName + "'");
                    return;
                }
            }
            for (int i = firstFilePos; i < argv.length; i++) {
                try {
                    processFile(argv[i], encodingName);
                } catch (FileNotFoundException e) {
                    System.out.println("File not found: \"" + argv[i] + "\"");
                } catch (IOException e) {
                    System.out.println("IO error scanning file \"" + argv[i] + "\"");
                    e.printStackTrace();
                } catch (Exception e) {
                    System.out.println("Unexpected exception:");
                    e.printStackTrace();
                }
            }
        }
    }

    private static void processFile(String filePath, String encodingName) throws IOException {
        try (FileInputStream stream = new FileInputStream(filePath);
             Reader reader = new InputStreamReader(stream, encodingName)) {
            AnalisadorLexico scanner = new AnalisadorLexico(reader);
            Token token;
            while (!scanner.zzAtEOF) {
                token = scanner.yylex();
                System.out.println(token);
            }
        }
    }
%}

%%

{ESPACO}     { /* Ignorar */ }

{INTEIRO}       { return new Token(yyline + 1, yycolumn + 1, Classe.cInt, new Valor(Integer.parseInt(yytext()))); }
{PALAVRA_RESERVADA} { return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext())); }
{IDENTIFICADOR} { return new Token(yyline + 1, yycolumn + 1, Classe.cId, new Valor(yytext())); }
{STRING}        { return new Token(yyline + 1, yycolumn + 1, Classe.cString, new Valor(yytext())); }
{REAL}          { return new Token(yyline + 1, yycolumn + 1, Classe.cReal, new Valor(Double.parseDouble(yytext()))); }


{OPERADORES} {
    switch (yytext()) {
        case ":":  return new Token(yyline + 1, yycolumn + 1, Classe.cDoisPontos, new Valor(yytext()));
        case ":=": return new Token(yyline + 1, yycolumn + 1, Classe.cAtribuicao, new Valor(yytext()));
        case "+":  return new Token(yyline + 1, yycolumn + 1, Classe.cMais, new Valor(yytext()));
        case "-":  return new Token(yyline + 1, yycolumn + 1, Classe.cMenos, new Valor(yytext()));
        case "/":  return new Token(yyline + 1, yycolumn + 1, Classe.cDivisao, new Valor(yytext()));
        case "*":  return new Token(yyline + 1, yycolumn + 1, Classe.cMultiplicacao, new Valor(yytext()));
        case ">":  return new Token(yyline + 1, yycolumn + 1, Classe.cMaior, new Valor(yytext()));
        case "<":  return new Token(yyline + 1, yycolumn + 1, Classe.cMenor, new Valor(yytext()));
        case ">=": return new Token(yyline + 1, yycolumn + 1, Classe.cMaiorIgual, new Valor(yytext()));
        case "<=": return new Token(yyline + 1, yycolumn + 1, Classe.cMenorIgual, new Valor(yytext()));
        case "<>": return new Token(yyline + 1, yycolumn + 1, Classe.cDiferente, new Valor(yytext()));
        case "=":  return new Token(yyline + 1, yycolumn + 1, Classe.cIgual, new Valor(yytext()));
        case ",":  return new Token(yyline + 1, yycolumn + 1, Classe.cVirgula, new Valor(yytext()));
        case ";":  return new Token(yyline + 1, yycolumn + 1, Classe.cPontoVirgula, new Valor(yytext()));
        case ".":  return new Token(yyline + 1, yycolumn + 1, Classe.cPonto, new Valor(yytext()));
    }
}
{PARENTESES} {
    switch (yytext()) {
        case "(": return new Token(yyline + 1, yycolumn + 1, Classe.cParEsq, new Valor(yytext()));
        case ")": return new Token(yyline + 1, yycolumn + 1, Classe.cParDir, new Valor(yytext()));
    }
}
