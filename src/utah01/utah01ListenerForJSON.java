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
import java.io.FileWriter;
import java.io.IOException;
import org.antlr.v4.runtime.misc.NotNull;

public class utah01ListenerForJSON extends utah01BaseListener {

    @Override
    public void exitActiveElement(@NotNull utah01Parser.ActiveElementContext ctx) {

        String fileName = ctx.ID().getText() + ".txt";
        String output = "{" + ctx.activeElementBody().val + ", \n\n\"name\" : \"" + ctx.ID().getText() + "\" \n}\n";
        try {
            FileWriter outputFile = new FileWriter(fileName);
            outputFile.write(output);
            outputFile.close();
        } catch (IOException e) {
            System.out.println("Can't open/write file for write : " + fileName);
        }
        /*SymbolTable.state.clear();
        SymbolTable.inPort.clear();
        SymbolTable.outPort.clear();
        SymbolTable.acceptableMessage.clear();
                */
    }
}
