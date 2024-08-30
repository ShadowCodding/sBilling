// Interfaces
interface LineInterface {
  Colors?: string[];
  DefaultColor: string;
}

function Line({ Colors, DefaultColor }: LineInterface) {
  return (
    <div className="zUI-Item">
      <div
        className="line"
        style={{
          background:
            Colors && Colors.length > 1
              ? `linear-gradient(to right, ${Colors.join(", ")})`
              : Colors && Colors.length === 1
              ? Colors[0]
              : DefaultColor,
        }}
      ></div>
    </div>
  );
}

export default Line;
