/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
//package utah01;
/**
 *
 * @author ntanaka
 */

import org.antlr.v4.runtime.ANTLRFileStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

public class Utah01 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        try {
            // make Lexer
            ANTLRFileStream inputStream = new ANTLRFileStream(args[0]);
            utah01Lexer lexer = new utah01Lexer(inputStream);

            // make Parser
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            utah01Parser parser = new utah01Parser(tokens);

            // make Walker
            ParseTreeWalker parseTreeWalker = new ParseTreeWalker();
            utah01ListenerForJSON listener = new utah01ListenerForJSON();
            ParserRuleContext parserRuleContext = parser.start();

            // do walk
            parseTreeWalker.walk(listener, parserRuleContext);
        } catch (Exception e) {
            System.out.println(e);
        }
        System.out.print("number of elements = ");
        System.out.println(SymbolTable.count);
    }
}
