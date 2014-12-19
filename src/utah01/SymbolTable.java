//package utah01;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author ntanaka
 */
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;

public class SymbolTable {

    static int count = 0;
    static ArrayList<String> state = new ArrayList<>();
    static ArrayList<String> inPort = new ArrayList<>();
    static ArrayList<String> outPort = new ArrayList<>();
    static Set<String> acceptableMessage = new HashSet<>();

    static String makeMessageList() {
        String string = "\n\"acceptableMessage\" : [";

        boolean ifFirst = true;
        for (String str : SymbolTable.acceptableMessage) {
            if (ifFirst) {
                string += "\"" + str + "\"";
                ifFirst = false;
            } else {
                string += " , " + "\"" + str + "\"";
            }
        }
        string += " ] \n";
        return string;
    }
}
