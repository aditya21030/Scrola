package com.example.scrola.service

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import kotlin.math.min

/**
 * Custom Canvas view rendering Scrola's 3D Brainy mascot inside the native floating overlay.
 * Scales proportionally from a 140x130 coordinate space and reacts to mood, blink, and skin.
 */
class BrainyOverlayView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    data class SkinPalette(
        val highlight: Int,
        val mid: Int,
        val shadow: Int,
        val crease: Int,
        val cheek: Int
    )

    companion object {
        private const val DESIGN_W = 140f
        private const val DESIGN_H = 130f

        private val SKINS = listOf(
            // 0: Classic Scrola Orange
            SkinPalette(
                highlight = Color.parseColor("#FFB07A"),
                mid = Color.parseColor("#FF6B24"),
                shadow = Color.parseColor("#C94108"),
                crease = Color.parseColor("#9B2E04"),
                cheek = Color.parseColor("#FF4D6D")
            ),
            // 1: Ember (Fiery Coral-Red)
            SkinPalette(
                highlight = Color.parseColor("#FCA5A5"),
                mid = Color.parseColor("#EF4444"),
                shadow = Color.parseColor("#B91C1C"),
                crease = Color.parseColor("#7F1D1D"),
                cheek = Color.parseColor("#FB7185")
            ),
            // 2: Golden
            SkinPalette(
                highlight = Color.parseColor("#FDE68A"),
                mid = Color.parseColor("#F59E0B"),
                shadow = Color.parseColor("#B45309"),
                crease = Color.parseColor("#78350F"),
                cheek = Color.parseColor("#FB7185")
            ),
            // 3: Frost
            SkinPalette(
                highlight = Color.parseColor("#BAE6FD"),
                mid = Color.parseColor("#38BDF8"),
                shadow = Color.parseColor("#0284C7"),
                crease = Color.parseColor("#075985"),
                cheek = Color.parseColor("#F472B6")
            ),
            // 4: Mint
            SkinPalette(
                highlight = Color.parseColor("#86EFAC"),
                mid = Color.parseColor("#22C55E"),
                shadow = Color.parseColor("#15803D"),
                crease = Color.parseColor("#14532D"),
                cheek = Color.parseColor("#FDA4AF")
            ),
            // 5: Midnight
            SkinPalette(
                highlight = Color.parseColor("#A1A1AA"),
                mid = Color.parseColor("#3F3F46"),
                shadow = Color.parseColor("#18181B"),
                crease = Color.parseColor("#09090B"),
                cheek = Color.parseColor("#FF6B24")
            )
        )
    }

    private var mood: String = "happy"
    private var skinIndex: Int = 0
    private var blinkProgress: Float = 0f // 0 = open, 1 = closed

    private val brainPath = Path()
    private val creasePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    private val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }
    private val outlinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    private val glossPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }
    private val cheekPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }
    private val eyePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#141218")
        style = Paint.Style.FILL
    }
    private val catchlightPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.FILL
    }
    private val featureStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#141218")
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    private val eyelidPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }

    private val blinkHandler = Handler(Looper.getMainLooper())
    private var blinkAnimator: ValueAnimator? = null
    private val blinkRunnable = object : Runnable {
        override fun run() {
            triggerBlink()
            blinkHandler.postDelayed(this, 3600L)
        }
    }

    init {
        buildBrainPath()
    }

    fun setMood(newMood: String) {
        val normalized = when (newMood.lowercase()) {
            "sleepy" -> "tired"
            "excited", "celebrating" -> "happy"
            else -> newMood.lowercase()
        }
        if (mood != normalized) {
            mood = normalized
            invalidate()
        }
    }

    fun setSkinIndex(index: Int) {
        val safe = index.coerceIn(0, SKINS.lastIndex)
        if (skinIndex != safe) {
            skinIndex = safe
            updateShaders()
            invalidate()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        blinkHandler.removeCallbacks(blinkRunnable)
        blinkHandler.postDelayed(blinkRunnable, 2200L)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        blinkHandler.removeCallbacks(blinkRunnable)
        blinkAnimator?.cancel()
        blinkAnimator = null
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        updateShaders()
    }

    private fun triggerBlink() {
        blinkAnimator?.cancel()
        blinkAnimator = ValueAnimator.ofFloat(0f, 1f, 0f).apply {
            duration = 170L
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { anim ->
                blinkProgress = anim.animatedValue as Float
                invalidate()
            }
            start()
        }
    }

    private fun palette(): SkinPalette = SKINS[skinIndex.coerceIn(0, SKINS.lastIndex)]

    private fun updateShaders() {
        val p = palette()
        bodyPaint.shader = RadialGradient(
            52f, 40f, 78f,
            intArrayOf(p.highlight, p.mid, p.shadow),
            floatArrayOf(0f, 0.56f, 1f),
            Shader.TileMode.CLAMP
        )
        glossPaint.shader = LinearGradient(
            36f, 20f, 76f, 52f,
            Color.argb(115, 255, 255, 255),
            Color.argb(0, 255, 255, 255),
            Shader.TileMode.CLAMP
        )
        outlinePaint.color = Color.argb(95, Color.red(p.crease), Color.green(p.crease), Color.blue(p.crease))
        creasePaint.color = Color.argb(145, Color.red(p.crease), Color.green(p.crease), Color.blue(p.crease))
        cheekPaint.color = Color.argb(120, Color.red(p.cheek), Color.green(p.cheek), Color.blue(p.cheek))
        eyelidPaint.color = p.mid
    }

    private fun buildBrainPath() {
        brainPath.reset()
        // Plump, friendly scalloped brain silhouette inside 140x130 coordinate space
        brainPath.moveTo(70f, 20f)
        // Top-right crown lobe
        brainPath.cubicTo(86f, 14f, 108f, 20f, 115f, 36f)
        // Upper-right bulge
        brainPath.cubicTo(126f, 41f, 130f, 56f, 124f, 68f)
        // Lower-right cheek bulge
        brainPath.cubicTo(130f, 80f, 123f, 99f, 107f, 104f)
        // Bottom-right curve into stem cleft
        brainPath.cubicTo(98f, 112f, 82f, 113f, 74f, 106f)
        // Subtle cute base dimple
        brainPath.cubicTo(71f, 109f, 69f, 109f, 66f, 106f)
        // Bottom-left curve
        brainPath.cubicTo(58f, 113f, 42f, 112f, 33f, 104f)
        // Lower-left cheek bulge
        brainPath.cubicTo(17f, 99f, 10f, 80f, 16f, 68f)
        // Upper-left bulge
        brainPath.cubicTo(10f, 56f, 14f, 41f, 25f, 36f)
        // Top-left crown lobe back to center dip
        brainPath.cubicTo(32f, 20f, 54f, 14f, 70f, 20f)
        brainPath.close()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (width == 0 || height == 0) return

        val availW = (width - paddingLeft - paddingRight).toFloat()
        val availH = (height - paddingTop - paddingBottom).toFloat()
        val scale = min(availW / DESIGN_W, availH / DESIGN_H)
        if (scale <= 0f) return

        val dx = paddingLeft + (availW - DESIGN_W * scale) / 2f
        val dy = paddingTop + (availH - DESIGN_H * scale) / 2f

        canvas.save()
        canvas.translate(dx, dy)
        canvas.scale(scale, scale)

        // Ensure shaders are initialized
        if (bodyPaint.shader == null) {
            updateShaders()
        }

        // 1. Soft brain silhouette
        canvas.drawPath(brainPath, bodyPaint)
        outlinePaint.strokeWidth = 3.2f
        canvas.drawPath(brainPath, outlinePaint)

        // 2. Top-left 3D specular gloss
        canvas.save()
        canvas.rotate(-16f, 48f, 36f)
        canvas.drawOval(RectF(30f, 24f, 68f, 44f), glossPaint)
        canvas.restore()

        // 3. Brain folds (sulci) keeping central face clear
        creasePaint.strokeWidth = 3.5f
        // Center top cleft
        canvas.drawLine(70f, 21f, 70f, 35f, creasePaint)
        // Left upper & lower folds
        val leftFold = Path().apply {
            moveTo(34f, 36f)
            quadTo(44f, 43f, 52f, 37f)
            moveTo(22f, 68f)
            quadTo(29f, 72f, 31f, 80f)
        }
        canvas.drawPath(leftFold, creasePaint)
        // Right upper & lower folds
        val rightFold = Path().apply {
            moveTo(106f, 36f)
            quadTo(96f, 43f, 88f, 37f)
            moveTo(118f, 68f)
            quadTo(111f, 72f, 109f, 80f)
        }
        canvas.drawPath(rightFold, creasePaint)

        // 4. Rosy cheeks (dimmed when sad/tired)
        val cheekAlpha = when (mood) {
            "sad" -> 45
            "tired" -> 70
            else -> 135
        }
        val p = palette()
        cheekPaint.color = Color.argb(cheekAlpha, Color.red(p.cheek), Color.green(p.cheek), Color.blue(p.cheek))
        canvas.drawOval(RectF(33f, 71f, 47f, 80f), cheekPaint)
        canvas.drawOval(RectF(93f, 71f, 107f, 80f), cheekPaint)

        // 5. Eyes & mood expressions
        drawEyesAndExpression(canvas)

        canvas.restore()
    }

    private fun drawEyesAndExpression(canvas: Canvas) {
        val leftEyeX = 52f
        val rightEyeX = 88f
        val eyeY = 60f
        val eyeRadius = 7.4f

        featureStrokePaint.strokeWidth = 4.2f

        // Brows for focused / sad / tired
        when (mood) {
            "focused" -> {
                canvas.drawLine(43f, 47f, 58f, 50f, featureStrokePaint)
                canvas.drawLine(97f, 47f, 82f, 50f, featureStrokePaint)
            }
            "sad" -> {
                canvas.drawLine(43f, 51f, 57f, 46f, featureStrokePaint)
                canvas.drawLine(97f, 51f, 83f, 46f, featureStrokePaint)
            }
            "tired" -> {
                canvas.drawLine(44f, 48f, 58f, 49f, featureStrokePaint)
                canvas.drawLine(96f, 48f, 82f, 49f, featureStrokePaint)
            }
        }

        // Blink or mood eyelids
        val effectiveClose = when {
            blinkProgress > 0.55f -> 1f
            mood == "tired" -> 0.52f
            else -> blinkProgress
        }

        if (effectiveClose > 0.85f) {
            // Closed blink arcs
            val blinkPath = Path().apply {
                moveTo(leftEyeX - eyeRadius, eyeY)
                quadTo(leftEyeX, eyeY + 4f, leftEyeX + eyeRadius, eyeY)
                moveTo(rightEyeX - eyeRadius, eyeY)
                quadTo(rightEyeX, eyeY + 4f, rightEyeX + eyeRadius, eyeY)
            }
            canvas.drawPath(blinkPath, featureStrokePaint)
        } else {
            // Open eyes
            val scaleY = (1f - effectiveClose * 0.65f).coerceAtLeast(0.35f)
            canvas.save()
            canvas.translate(0f, eyeY * (1f - scaleY))
            canvas.scale(1f, scaleY)

            canvas.drawCircle(leftEyeX, eyeY, eyeRadius, eyePaint)
            canvas.drawCircle(rightEyeX, eyeY, eyeRadius, eyePaint)

            // Catchlight sparkles
            canvas.drawCircle(leftEyeX - 2.3f, eyeY - 2.4f, 2.4f, catchlightPaint)
            canvas.drawCircle(rightEyeX - 2.3f, eyeY - 2.4f, 2.4f, catchlightPaint)
            canvas.drawCircle(leftEyeX + 2.2f, eyeY + 2.3f, 1.1f, catchlightPaint)
            canvas.drawCircle(rightEyeX + 2.2f, eyeY + 2.3f, 1.1f, catchlightPaint)
            canvas.restore()

            if (mood == "tired") {
                // Subtle upper lid line for sleepy look
                canvas.drawLine(
                    leftEyeX - eyeRadius - 1f, eyeY - 2.5f,
                    leftEyeX + eyeRadius + 1f, eyeY - 2.5f,
                    featureStrokePaint
                )
                canvas.drawLine(
                    rightEyeX - eyeRadius - 1f, eyeY - 2.5f,
                    rightEyeX + eyeRadius + 1f, eyeY - 2.5f,
                    featureStrokePaint
                )
            }
        }

        // Mouth
        val mouthPath = Path()
        featureStrokePaint.strokeWidth = 4.4f
        when (mood) {
            "happy" -> {
                mouthPath.moveTo(59f, 77f)
                mouthPath.quadTo(70f, 89f, 81f, 77f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
            "neutral" -> {
                mouthPath.moveTo(61f, 79f)
                mouthPath.quadTo(70f, 84f, 79f, 79f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
            "focused" -> {
                mouthPath.moveTo(62f, 80f)
                mouthPath.quadTo(71f, 82f, 79f, 77f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
            "tired" -> {
                mouthPath.moveTo(63f, 81f)
                mouthPath.quadTo(70f, 79.5f, 77f, 81f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
            "sad" -> {
                mouthPath.moveTo(60f, 84f)
                mouthPath.quadTo(70f, 75f, 80f, 84f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
            else -> {
                mouthPath.moveTo(59f, 77f)
                mouthPath.quadTo(70f, 88f, 81f, 77f)
                canvas.drawPath(mouthPath, featureStrokePaint)
            }
        }
    }
}
