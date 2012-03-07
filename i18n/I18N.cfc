<!---
	Class: I18N
	Provides basic internationalization support for the Basis framework. This component gives
	the ability to work with resource bundles or property files, as well as simple date
	and time formatting. These are all based on Locale information.

	Extends:
		<Basis.Plugin>

	Author:
		Adam Presley

	Type:
		Basis Plugin - Session

	Example:
		> &lt;!--- Load the "main" properties file for US English ---&gt;
		> <cfset session.i18n.setLocale("en", "US").loadResourceBundles([ "main" ]) />
		>
		> &lt;!--- Display the value from the key main.title ---&gt;
		> <cfoutput>#session.i18n.get("main.title")#</cfoutput>

	History:
		- 03.06.2012 | AdamP    | Created


	Section: Variables

	Private Variables:
		__localeSettings - Structure containing the current language, country, and locale object
		__properties - Structure containing all key/value pairs from loaded resource bundles

	Public Variables:
		FORMAT_SHORT - Constant for a short date and time format
		FORMAT_MEDIUM - Constant for a medium date and time format
		FORMAT_LONG - Constant for a long date and time format


	Section: Functions
--->
<cfcomponent extends="Basis.Plugin" output="false">

	<cfset variables.__localeSettings = {
		language = "en",
		country = "US",
		locale = createObject("java", "java.util.Locale").init("en", "US"),
		dateFormatObj = createObject("java", "java.text.DateFormat")
	} />

	<cfset variables.__properties = {} />


	<cfset this.FORMAT_SHORT = 3 />
	<cfset this.FORMAT_MEDIUM = 2 />
	<cfset this.FORMAT_LONG = 1 />


	<cffunction name="initPlugin" output="false">
		<cfset this.name = "Internationalization and Globalization" />
		<cfset this.scope = "session" />
		<cfset this.referenceName = "i18n" />
	</cffunction>

	<cffunction name="setLocale" output="false">
		<cfargument name="language" type="string" required="true" />
		<cfargument name="country" type="string" required="true" />

		<cfset variables.__localeSettings.language = arguments.language />
		<cfset variables.__localeSettings.country = arguments.country />
		<cfset variables.__localeSettings.locale = createObject("java", "java.util.Locale").init(arguments.language, arguments.country) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getLocaleSettings" output="false">
		<cfreturn variables.__localeSettings />
	</cffunction>

	<cffunction name="loadResourceFile" output="false">
		<cfargument name="baseName" type="string" required="true" />

		<cfset var stream = createObject("java", "java.io.FileInputStream").init(expandPath("#arguments.baseName#_#variables.__localeSettings.language#_#variables.__localeSettings.country#.properties")) />
		<cfset var bundle = createObject("java", "java.util.PropertyResourceBundle").init(stream) />

		<cfset stream.close() />
		<cfset __populateProperties(bundle) />
	</cffunction>

	<cffunction name="loadResourceFiles" output="false">
		<cfargument name="baseNames" type="array" required="true" />

		<cfset var item = "" />

		<cfloop array="#arguments.baseNames#" index="item">
			<cfset loadResourceFile(item) />
		</cfloop>
	</cffunction>

	<cffunction name="loadResourceBundle" output="false">
		<cfargument name="baseName" type="string" required="true" />

		<cfset var bundle = createObject("java", "java.util.ResourceBundle").getBundle("#arguments.baseName#", variables.__localeSettings.locale) />
		<cfset __populateProperties(bundle) />
	</cffunction>

	<cffunction name="loadResourceBundles" output="false">
		<cfargument name="baseNames" type="array" required="true" />

		<cfset var item = "" />

		<cfloop array="#arguments.baseNames#" index="item">
			<cfset loadResourceBundle(item) />
		</cfloop>
	</cffunction>

	<cffunction name="get" output="false">
		<cfargument name="key" type="string" required="true" />

		<cfif !structKeyExists(variables.__properties, arguments.key)>
			<cfthrow message="Invalid I18N key" detail="The key #arguments.key# could not be found in any loaded resource bundles" />
		</cfif>

		<cfreturn duplicate(variables.__properties[arguments.key]) />
	</cffunction>

	<cffunction name="getAll" output="false">
		<cfreturn duplicate(variables.__properties) />
	</cffunction>

	<cffunction name="dateFormat" output="false">
		<cfargument name="date" type="date" required="true" />
		<cfargument name="style" type="numeric" required="false" default="#this.FORMAT_SHORT#" />

		<cfreturn __getDateFormatter(arguments.style).format(arguments.date) />
	</cffunction>

	<cffunction name="timeFormat" output="false">
		<cfargument name="date" type="date" required="true" />
		<cfargument name="style" type="numeric" required="false" default="#this.FORMAT_SHORT#" />

		<cfreturn __getTimeFormatter(arguments.style).format(arguments.date) />		
	</cffunction>

	<cffunction name="dateTimeFormat" output="false">
		<cfargument name="date" type="date" required="true" />
		<cfargument name="dateStyle" type="numeric" required="false" default="#this.FORMAT_SHORT#" />
		<cfargument name="timeStyle" type="numeric" required="false" default="#this.FORMAT_SHORT#" />
		
		<cfreturn __getDateTimeFormatter(arguments.dateStyle, arguments.timeStyle).format(arguments.date) />
	</cffunction>

	<cffunction name="__populateProperties" access="private" output="false">
		<cfargument name="bundle" type="any" required="true" />

		<cfset var keys = "" />
		<cfset var key = "" />

		<cfset keys = bundle.getKeys() />
		<cfloop condition="keys.hasMoreElements()">
			<cfset key = keys.nextElement() />
			<cfset variables.__properties[key] = bundle.getString(key) />
		</cfloop>
	</cffunction>

	<cffunction name="__getDateFormatter" access="private" output="false">
		<cfargument name="style" type="numeric" required="true" />
		<cfreturn variables.__localeSettings.dateFormatObj.getDateInstance(arguments.style, variables.__localeSettings.locale) />
	</cffunction>

	<cffunction name="__getTimeFormatter" access="private" output="false">
		<cfargument name="style" type="numeric" required="true" />
		<cfreturn variables.__localeSettings.dateFormatObj.getTimeInstance(arguments.style, variables.__localeSettings.locale) />		
	</cffunction>

	<cffunction name="__getDateTimeFormatter" access="private" output="false">
		<cfargument name="dateStyle" type="numeric" required="true" />
		<cfargument name="timeStyle" type="numeric" required="true" />

		<cfreturn variables.__localeSettings.dateFormatObj.getDateTimeInstance(arguments.dateStyle, arguments.timeStyle, variables.__localeSettings.locale) />		
	</cffunction>

</cfcomponent>