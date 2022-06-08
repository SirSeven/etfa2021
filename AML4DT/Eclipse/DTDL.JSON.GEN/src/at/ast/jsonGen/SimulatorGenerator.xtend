package at.ast.jsonGen

import org.eclipse.xtext.generator.IGenerator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import DTML.*
import DTML.impl.RelationshipInstanceImpl
import DTML.impl.StringInstanceImpl
import DTML.impl.TelemetryUnaryConditionImpl
import DTML.impl.PropertyUnaryConditionImpl
import DTML.impl.IntInstanceImpl
import DTML.impl.LogActionImpl

class SimulatorGenerator implements IGenerator {
	// Helper functions
	def dispatch serialize(DTMI dtmi){
		'''«dtmi.scheme»:«dtmi.path»;«dtmi.version»'''
	}
	
	def dispatch serialize(DTElement ic){
		'''
		«IF ic.displayName !== null»
		"displayName": "«ic.displayName»",
		«ENDIF»
		«IF ic.comment !== null»
		"comment": "«ic.comment»",
		«ENDIF»
		«IF ic.description !== null»
		"description": "«ic.description»",
		«ENDIF»
		«IF ic.id !== null»
		"@id": "«ic.id.serialize»",
		«ENDIF»
		'''
	}
	// Generator functions

	
	def dispatch generateJson(Interface interf){
		'''
		   "@type": "Interface",
		   «(interf as DTElement).serialize»
		   «IF interf.contents.size > 0»
		   "contents":[
   		   «var contents = interf.contents.filter[c|!(c instanceof Condition)]»
		   «FOR i : 0..<contents.size»
		   «var cont = contents.get(i)»
		   		{
		   		«cont.generateJson»
		   		}«if(i < contents.size - 1) ''','''»
		   «ENDFOR»
		   ],
		   «ENDIF»
		   "@context": "dtmi:dtdl:context;2"
		'''
	}
	
	def dispatch generateJson(Relationship rel){
		'''
		"@type": "Relationship",
		«(rel as DTElement).serialize»
		«IF rel.target !== null»
		"target": "«rel.target.id.serialize»",
		«ENDIF»
		«IF rel.maxMultiplicity >= 0»
		"maxMultiplicity": «rel.maxMultiplicity»,
		«ENDIF»
		"minMultiplicity": «rel.minMultiplicity»,
		"writable": «rel.writable»,
		«IF rel.properties !== null»
		"properties": [
			«FOR i : 0..<rel.properties.size»
				«var prop = rel.properties.get(i)»
				{
				«prop.generateJson»
				}«if(i < rel.properties.size - 1) ''','''»
			«ENDFOR»
		],
		«ENDIF»
		"name": "«rel.name»"
		'''
	}
	
	def dispatch generateJson(Component comp){
		'''
		"@type": "Component",
		"name": "«comp.name»",
		"schema": "«comp.schema.id.serialize»"
		'''
	}
	
	def dispatch generateJson(Telemetry tel){
		'''
		"@type": [
			"Telemetry"«IF tel.type !== Type.NONE»,
			"«tel.type»"«ENDIF»
		],
		"schema": "«tel.schema»",
		«(tel as DTElement).serialize»
		"name": "«tel.name»"
		'''
	}
	
	def dispatch generateJson(Property prop){
		'''
		"@type": [
			"Property"«IF prop.type !== Type.NONE»,
			"«prop.type»"«ENDIF»
		],
		"schema": "«prop.schema»",
		«(prop as DTElement).serialize»
		"name": "«prop.name»"
		'''
	}
	
	def dispatch generateJson(Command com){
		'''
		"@type": [
			"Command"
		],
		«(com as DTElement).serialize»
		«IF com.request !== null»
		"request": «com.request.get(0).generateJson»,
		«ENDIF»
		«IF com.response !== null»
		"response": «com.request.get(0).generateJson»,
		«ENDIF»
		"name": "«com.name»"
		'''
	}
	
	def dispatch generateJson(CommandPayload cp){
		'''
		{
			«IF cp.displayName !== null»
			"displayName": "«cp.displayName»",
			«ENDIF»
			«IF cp.comment !== null»
			"comment": "«cp.comment»",
			«ENDIF»
			«IF cp.description !== null»
			"description": "«cp.description»"
			«ENDIF»
			"name": "«cp.name»",
			"schema": "«cp.schema»"
		}'''
	}
	
	def dispatch generateJson(DigitalTwin dt){
		'''
		"dtid": "«dt.name»",
		"content": {
		«FOR cont : dt.contents»
			«IF cont.class != RelationshipInstanceImpl»
				«cont.serialize»,
			«ENDIF»
		«ENDFOR»
			"$metadata": {
				"$model": "«dt.type.id.serialize»"
			}
		}, 
		"relationships": [
		«FOR i : 0..<dt.contents.size»
		«var cont = dt.contents.get(i)»
			«IF cont.class == RelationshipInstanceImpl»
				{
				«cont.serialize»
				}«if(i < dt.contents.size - 1) ''','''»
			«ENDIF»
			
		«ENDFOR»
		]
		'''
	}
	
	def dispatch serialize(RelationshipInstance relInst){
		'''
		   "id": "«relInst.name»",
		   "content": {
		   	"$targetId": "«relInst.target.name»",
		   	"relationshipName": "«relInst.type.name»"
		   }
		'''
	}
	
	def dispatch serialize(PropertyInstance propInst){
		'''"«propInst.name»": «propInst.value.serialize()»'''
	}
		
	def dispatch serialize(ComponentInstance compInst){
		'''
		   "«compInst.type.name»": {
		   	"$metadata": {},
		   	«FOR i : 0..<compInst.contents.size»
				«var cont = compInst.contents.get(i)»
				«cont.serialize»
				«if(i < compInst.contents.size - 1) ''','''»
			«ENDFOR»
		   }
		'''
	}
	
	def dispatch serialize(AzureResource azureResource) {
		'''
		"«azureResource.type»": {
			"name": "«azureResource.name»",
			"resourceGroup": "«azureResource.resourceGroup»"
		}'''
	}
	
	def dispatch generateJsonPathCondition(Condition condition) {
		if(condition.class == UnaryCondition) {
			(condition as UnaryCondition).serialize()
		}
	}
	
	def dispatch generateJsonPathCondition(UnaryCondition condition) {
		if(condition.class == TelemetryUnaryCondition) {
			(condition as TelemetryUnaryCondition).serialize()
		} else if(condition.class == PropertyUnaryCondition) {
			(condition as PropertyUnaryCondition).serialize()
		}
	}
		
	def dispatch serialize(StringInstanceImpl stringInstance) {
		''''«stringInstance.value»' '''
	}
	
	def dispatch serialize(IntInstanceImpl intInstance) {
		'''«intInstance.value»'''
	}
	
	def dispatch generateJsonPathCondition(TelemetryUnaryConditionImpl condition) {
		'''"$.[?(@.Property=='«condition.telemetry.displayName»'&&@.Value«SimulatorGeneratorHelper.getInverseOperationSign(condition.operation)»«condition.value.serialize»)]"'''
	}
	
	def dispatch generateJsonPathCondition(PropertyUnaryConditionImpl condition) {
		'''"$.[?(@.Property=='«condition.property.displayName»'&&@.Value«SimulatorGeneratorHelper.getInverseOperationSign(condition.operation)»«condition.value.serialize»)]"'''
	}
	
	def dispatch serialize(LogAction action) {
		'''{
			"type":"«action.class.simpleName»",
			"config": {
				"logLevel": "«action.logLevel»",
				"message": "«action.message»"
			}
		}'''
	}
	
	override doGenerate(Resource input, IFileSystemAccess fsa) {
		val root = input.contents.findFirst[o|o instanceof DigitalTwinEnvironment] as DigitalTwinEnvironment
		// generate model json files
		root.types.filter[o|o instanceof Interface].forEach[o|
			val temp = o as Interface
			val content = '''
				{
					«temp.generateJson»
				}
				'''
			//fsa.generateFile('''«input.URI.trimFileExtension.lastSegment».json''', content)
			fsa.generateFile('''schemas/«temp.displayName».json''', content)
		]
		
		// generate twin json files
		root.instances.filter[o|o instanceof DigitalTwin].forEach[o|
			val temp = o as DigitalTwin
			val content = '''
				{
					«temp.generateJson»
				}
				'''
			//fsa.generateFile('''«input.URI.trimFileExtension.lastSegment».json''', content)
			fsa.generateFile('''instances/«temp.name».json''', content)
		]
		
		// generate twin device-configuration json files
		root.instances.filter[o|o instanceof DigitalTwin].forEach[o|
			val twin = o as DigitalTwin
			if(twin.configurationProperties.size > 0) {
				val content = '''
				{
					«FOR i : 0..<twin.configurationProperties.size»
						«var configProp = twin.configurationProperties.get(i)»
						«IF configProp.value instanceof StringInstance»
							"«configProp.name»":"«SimulatorGeneratorHelper.escapeJson((configProp.value as StringInstance).value)»"«IF(i < twin.configurationProperties.size - 1)»,«ENDIF»
						«ELSEIF configProp.value instanceof IntInstance»
							"«configProp.name»":"«(configProp.value as IntInstance).value»"«IF(i < twin.configurationProperties.size - 1)»,«ENDIF»
						«ENDIF»
					«ENDFOR»
				}
				'''
				fsa.generateFile('''instance-configs/«twin.name».config.json''', content)
			}
		]
				
		// generate config file
		val configContent = '''
			{
				«root.ioTHubResource.serialize»,
				«root.digitalTwinsResource.serialize»,
				«root.appConfigurationResource.serialize»
			}
		'''
		fsa.generateFile('''azureConfig.json''', configContent)
		
		// generate validation rule json paths
		val interfaces = root.types.filter[o|o instanceof Interface]
		var firstWritten = false
		val validationsContent = '''
		{
			"Validators": {
			«FOR i : 0..<interfaces.size»
				«val interface  = interfaces.get(i)»
				«val typeConditions = interface.contents.filter[content|content instanceof Condition]»
				«IF typeConditions.size > 0»
					«IF firstWritten»,«ENDIF»"«interface.displayName»": [
					«FOR j : 0..<typeConditions.size»
					«var condition = typeConditions.get(j) as Condition»
						{
							"jsonPathQuery": «condition.generateJsonPathCondition»,
							"continue": «condition.continue»,
							"actions": [
								«FOR k : 0..<condition.actions.size»
								«condition.actions.get(k).serialize»«IF(k < condition.actions.size - 1)»,«ENDIF»
								«ENDFOR»
							]
						}«IF(j < typeConditions.size - 1)»,«ENDIF»
					«ENDFOR»
					]«{firstWritten = true; ""}»
				«ENDIF»
			«ENDFOR»
			}
		}
		'''
		fsa.generateFile('''validators.json''', validationsContent)
	}
}