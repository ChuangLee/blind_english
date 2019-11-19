package pro.lichuang.blindenglish.player

import android.graphics.Bitmap
import android.os.Parcel
import android.os.Parcelable

class Music(
        val map: HashMap<String, Any>
) : Parcelable {

    fun getId(): Long {
        return (map["id"] as Number).toLong()
    }

    fun getTitle(): String {
        return map["title"] as String
    }

    fun getSubTitle(): String {
        return map["subTitle"] as String
    }

    fun getPlayUrl(): String {
        return map["url"] as String
    }

    fun isFavorite(): Boolean {
        return map["isFavorite"] as? Boolean ?: false
    }

    fun getCoverBitmap(): Bitmap? {
        return null
    }

    @Suppress("UNCHECKED_CAST")
    constructor(source: Parcel) : this(
            source.readHashMap(null) as HashMap<String, Any>
    )


    override fun describeContents() = 0

    override fun writeToParcel(dest: Parcel, flags: Int) = with(dest) {
        writeSerializable(map)
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Music) return false

        if (getId() != other.getId()) return false

        return true
    }

    override fun hashCode(): Int {
        return getId().hashCode()
    }

    override fun toString(): String {
        return "Music{${getId()},title = ${getTitle()}}"
    }

    companion object {
        @Suppress("unused")
        @JvmField
        val CREATOR: Parcelable.Creator<Music> = object : Parcelable.Creator<Music> {
            override fun createFromParcel(source: Parcel): Music = Music(source)
            override fun newArray(size: Int): Array<Music?> = arrayOfNulls(size)
        }
    }
}