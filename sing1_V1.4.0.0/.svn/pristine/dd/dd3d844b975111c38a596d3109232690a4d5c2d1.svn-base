package cn.kuwo.base.codec;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import android.content.Context;
import cn.kuwo.framework.log.KuwoLog;
import dalvik.system.DexClassLoader;
import dalvik.system.VMStack;

public class CodecPluginLoader {

	private static CodecPluginLoader pluginLoader = null;
	private static final String tmp_dir = "/sdcard/.tmp/";
	private static final String config_file = "config.xml";

	// tag name
	private static final String tag_codec = "codec";
	private static final String tag_java = "java";
	private static final String tag_lib = "lib";

	// attribute name
	private static final String att_codecname = "name";
	private static final String att_codectype = "type";
	private static final String att_classname = "classname";
	private static final String att_formats = "formats";

	static class PluginInfo {
		String pluginName = null;
		String pluginClassName = null;
		String pluginFileName = null;
		String pluginClass = null;
		String[] pluginFormats = null;
	}

	class CodecInfo {
		DexClassLoader localDexClassLoader = null;
		Class<? extends Decoder> localClass = null;
		String pluginName;
		String[] pluginFormats = null;
	}

	public static CodecPluginLoader getCodecPluginLoader() {
		return (pluginLoader == null ? (pluginLoader = new CodecPluginLoader())
				: pluginLoader);
	}

	private CodecPluginLoader() {
	}

	// <resources>
	// <codec name="flac" version="0.1">
	// <java class="codec" sub="flac"
	// classname="cn.kuwo.base.codec.NativeFLACDecoder" version="0.1" />
	// <lib class="decoder" sub="flac" classname="libkwflac.so" version="0.1" />
	// </codec>
	// </resources>
	private static PluginInfo parse(InputStream stream) {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		PluginInfo plugin_info = null;
		try {
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document dom = builder.parse(stream);
			Element root = dom.getDocumentElement();
			NodeList items = root.getElementsByTagName(tag_codec);
			plugin_info = new PluginInfo();
			for (int i = 0; i < items.getLength(); i++) {
				Node item = items.item(i);
				plugin_info.pluginName = item.getAttributes()
						.getNamedItem(att_codecname).getNodeValue();
				plugin_info.pluginClass = item.getAttributes()
						.getNamedItem(att_codectype).getNodeValue();
				NodeList properties = item.getChildNodes();
				for (int j = 0; j < properties.getLength(); j++) {
					Node property = properties.item(j);
					String name = property.getNodeName();
					if (name.equalsIgnoreCase(tag_java)) {
						plugin_info.pluginClassName = property.getAttributes()
								.getNamedItem(att_classname).getNodeValue();
						plugin_info.pluginFormats = property.getAttributes()
								.getNamedItem(att_formats).getNodeValue().split(",");
					} else if (name.equalsIgnoreCase(tag_lib)) {
						plugin_info.pluginFileName = property.getAttributes()
								.getNamedItem(att_classname).getNodeValue();
					}
				}
				if (plugin_info.pluginClass != null
						&& plugin_info.pluginClassName != null
						&& plugin_info.pluginFileName != null)
					break;
			}
			
			return plugin_info;
		} catch (Exception e) {
		    KuwoLog.printStackTrace(e);
		    return null;
		}
	}
	
	private ClassLoader getStackLoader() {
	    return VMStack.getCallingClassLoader();
	}

	public AudioCodec LoadPlugin(String jar_path, Context ctxt) {
		if (jar_path == null)
			return null;
		
		String so_path = ctxt.getFilesDir().getPath();
		DexClassLoader localDexClassLoader = null;
		Class localClass = null;
		String pluginName;
		String[] formats;
		try {
			new File(so_path).mkdirs();
			new File(tmp_dir).mkdirs();
			localDexClassLoader = new DexClassLoader(jar_path, tmp_dir, null,
					getStackLoader());
			PluginInfo pi = null;
			InputStream config_is = localDexClassLoader.getResourceAsStream(config_file);

			if (config_is != null) {
				pi = parse(config_is);
				config_is.close();
			}

			if (pi == null || pi.pluginClass == null || pi.pluginClassName == null
					|| pi.pluginFileName == null)
				return null;
			
			so_path = (so_path.endsWith(File.separator) ? so_path.substring(0,
					so_path.length() - 1) : so_path);
			String solib = so_path + File.separator + pi.pluginFileName;
			if (pi.pluginFileName != null) {
				InputStream is = localDexClassLoader
						.getResourceAsStream(pi.pluginFileName);

				FileOutputStream oSoLib = new FileOutputStream(new File(solib));

				int len = 0;
				byte[] buf = new byte[1024];
				while ((len = is.read(buf)) > 0) {
					oSoLib.write(buf, 0, len);
				}

				is.close();
				oSoLib.close();
			}
			// 获取类型
			localClass = localDexClassLoader.loadClass(pi.pluginClassName);
			pluginName = pi.pluginName;
			formats = pi.pluginFormats;

			// 加载动态库
			System.load(solib);

			// 动态注册函数隐射
			if (localClass != null)
				registerClassMethods(localClass);
			else
				return null;

			return (new AudioCodec(pluginName, localClass, formats));
			
		} catch (Exception ex) {
		    KuwoLog.printStackTrace(ex);
			return null;
		}
		
		
	}

    public AudioCodec loadPlugin(String jarPath, Context ctxt) {
        return LoadPlugin(jarPath, ctxt);
    }

    private native boolean registerClassMethods(Class clazz);
}
