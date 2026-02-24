///
/// Copyright (c) 2026 Netmera Research.
///

package com.netmera.flutterexample.config

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast

class NetmeraConfigActivity : Activity() {

    private lateinit var spinner: Spinner
    private lateinit var baseUrlInput: EditText
    private lateinit var apiKeyInput: EditText
    private lateinit var prefs: android.content.SharedPreferences

    companion object {
        private const val COLOR_HEADER_BG = 0xFFF5F5F5.toInt()
        private const val COLOR_TITLE = 0xFF424242.toInt()
        private const val COLOR_LABEL = 0xFF616161.toInt()
        private const val COLOR_BUTTON_BLUE = 0xFF2196F3.toInt()
        private const val COLOR_BACKGROUND = 0xFFFFFFFF.toInt()
        private const val COLOR_INPUT_BG = 0xFFFAFAFA.toInt()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        prefs = NetmeraConfigProvider.getPreferences(this)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(COLOR_BACKGROUND)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(COLOR_HEADER_BG)
            setPadding(dp(20), dp(16), dp(20), dp(16))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        header.addView(TextView(this).apply {
            text = "Netmera Flutter Config"
            setTextColor(COLOR_TITLE)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 20f)
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        })
        root.addView(header)

        val scroll = ScrollView(this).apply {
            setBackgroundColor(COLOR_BACKGROUND)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        val content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(COLOR_BACKGROUND)
            setPadding(dp(24), dp(24), dp(24), dp(24))
        }

        content.addView(label("Environment"))
        val envValues = listOf(
            NetmeraEnvironment.TEST,
            NetmeraEnvironment.PREPROD,
            NetmeraEnvironment.PROD,
            NetmeraEnvironment.CUSTOM
        )
        val envNames = envValues.map { it.displayName }
        spinner = Spinner(this).apply {
            adapter = spinnerAdapter(envNames)
            setPadding(dp(14), dp(14), dp(14), dp(14))
            setBackgroundColor(COLOR_INPUT_BG)
            layoutParams = linearParams(0, dp(16))
        }
        val savedEnvKey = prefs.getString("environment", NetmeraEnvironment.PREPROD.key)
        val savedIndex = envValues.indexOfFirst { it.key == savedEnvKey }.takeIf { it >= 0 } ?: 1
        spinner.setSelection(savedIndex)
        content.addView(spinner)

        // Base URL
        content.addView(label("Base URL", topMargin = dp(24)))
        baseUrlInput = EditText(this).apply {
            hint = "Base URL"
            setPadding(dp(12), dp(12), dp(12), dp(12))
            setBackgroundColor(COLOR_INPUT_BG)
            layoutParams = linearParams(0, dp(8))
        }
        content.addView(baseUrlInput)

        // API Key
        content.addView(label("API Key", topMargin = dp(24)))
        apiKeyInput = EditText(this).apply {
            hint = "API Key"
            setPadding(dp(12), dp(12), dp(12), dp(12))
            setBackgroundColor(COLOR_INPUT_BG)
            layoutParams = linearParams(0, dp(8))
        }
        content.addView(apiKeyInput)

        val saveButton = Button(this).apply {
            text = "SAVE"
            setTextColor(Color.WHITE)
            setAllCaps(true)
            setPadding(0, dp(14), 0, dp(14))
            background = roundedRectDrawable(COLOR_BUTTON_BLUE, dp(12))
            layoutParams = linearParams(0, dp(32)).apply {
                topMargin = dp(28)
            }
            setOnClickListener { saveAndFinish() }
        }
        content.addView(saveButton)

        content.addView(TextView(this).apply {
            text = "Değişikliklerin uygulanması için ana uygulama ikonundan uygulamayı açın."
            setTextColor(COLOR_LABEL)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dp(20), 0, 0)
            layoutParams = linearParams(0, 0)
        })

        scroll.addView(content)
        root.addView(scroll)
        setContentView(root)

        updateFieldsFromSpinner(envValues[savedIndex])
        spinner.setOnItemSelectedListener(object : android.widget.AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: android.widget.AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                if (position in envValues.indices) updateFieldsFromSpinner(envValues[position])
            }
            override fun onNothingSelected(parent: android.widget.AdapterView<*>?) {}
        })
    }

    private fun updateFieldsFromSpinner(env: NetmeraEnvironment) {
        if (env == NetmeraEnvironment.CUSTOM) {
            baseUrlInput.isEnabled = true
            apiKeyInput.isEnabled = true
            baseUrlInput.setText(prefs.getString("baseUrl", NetmeraEnvironment.PREPROD.url))
            apiKeyInput.setText(prefs.getString("apiKey", NetmeraEnvironment.PREPROD.defaultApiKey))
        } else {
            baseUrlInput.isEnabled = false
            apiKeyInput.isEnabled = false
            baseUrlInput.setText(env.url)
            apiKeyInput.setText(env.defaultApiKey)
        }
    }

    private fun saveAndFinish() {
        val envValues = listOf(
            NetmeraEnvironment.TEST,
            NetmeraEnvironment.PREPROD,
            NetmeraEnvironment.PROD,
            NetmeraEnvironment.CUSTOM
        )
        val pos = spinner.selectedItemPosition.coerceIn(0, envValues.lastIndex)
        val env = envValues[pos]
        val baseUrl = baseUrlInput.text.toString().trim().ifEmpty { env.url.ifEmpty { NetmeraEnvironment.PREPROD.url } }
        val apiKey = apiKeyInput.text.toString().trim().ifEmpty { env.defaultApiKey.ifEmpty { NetmeraEnvironment.PREPROD.defaultApiKey } }

        NetmeraConfigProvider.saveConfig(prefs, env, baseUrl, apiKey)
        Toast.makeText(this, "Ayarlar kaydedildi. Uygulama kapatılıyor; ana ikondan tekrar açın.", Toast.LENGTH_LONG).apply {
            setGravity(Gravity.CENTER, 0, 0)
            show()
        }
        finish()
        Handler(Looper.getMainLooper()).postDelayed({
            Process.killProcess(Process.myPid())
        }, 1000)
    }

    private fun spinnerAdapter(items: List<String>): ArrayAdapter<String> {
        return object : ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, items) {
            override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                return makeSpinnerRow(getItem(position) ?: "", false)
            }
            override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
                return makeSpinnerRow(getItem(position) ?: "", true)
            }
        }.apply {
            setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        }
    }

    private fun makeSpinnerRow(text: String, isDropdown: Boolean): TextView {
        return TextView(this).apply {
            this.text = text
            setTextColor(COLOR_TITLE)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 17f)
            setPadding(dp(14), if (isDropdown) dp(18) else dp(4), dp(14), if (isDropdown) dp(18) else dp(4))
            if (isDropdown) minimumHeight = dp(52)
        }
    }

    private fun label(text: String, topMargin: Int = 0): TextView {
        return TextView(this).apply {
            this.text = text
            setTextColor(COLOR_LABEL)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 14f)
            layoutParams = linearParams(0, dp(8)).apply {
                if (topMargin > 0) this.topMargin = topMargin
            }
        }
    }

    private fun roundedRectDrawable(color: Int, cornerRadiusPx: Int): GradientDrawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = cornerRadiusPx.toFloat()
        }
    }

    private fun linearParams(marginHorizontal: Int, marginBottom: Int): LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply {
            if (marginHorizontal > 0) {
                marginStart = marginHorizontal
                marginEnd = marginHorizontal
            }
            bottomMargin = marginBottom
        }
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }
}
