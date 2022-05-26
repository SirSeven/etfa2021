package at.ast.jsonGen;

import DTML.ConditionOperationType;

public class SimulatorGeneratorHelper {

	public static String escapeJson(String raw) {
		String escaped = raw;
		escaped = escaped.replace("\\", "\\\\");
		escaped = escaped.replace("\"", "\\\"");
		escaped = escaped.replace("\b", "\\b");
		escaped = escaped.replace("\f", "\\f");
		escaped = escaped.replace("\n", "\\n");
		escaped = escaped.replace("\r", "\\r");
		escaped = escaped.replace("\t", "\\t");
		// TODO: escape other non-printing characters using uXXXX notation
		return escaped;
	}

	public static String getInverseOperationSign(ConditionOperationType conditionOperationType) {
		switch (conditionOperationType) {
		case EQUAL:
			return "!=";
		case NOT_EQUAL:
			return "==";
		case LOWER_THAN:
			return ">=";
		case LOWER_OR_EQUAL_THAN:
			return ">";
		case GREATER_THAN:
			return "<=";
		case GREATER_OR_EQUAL_THAN:
			return "<";
		default:
			return "";
		}
	}

}
